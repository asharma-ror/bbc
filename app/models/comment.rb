require 'digest/md5'
require 'net/http'
require 'cgi'

class Comment < ActiveRecord::Base
  class AkismetError < StandardError
  end
  attr_accessible :topic_id, :moderation_status, :author_name, :author_email, :author_ip, :author_user_agent, :referer, :content, :comment_number, :vote_counts, :flag_status, :votes_value, :parent_id
  COMMENT_EDIT_DURATION = 1.hour
  
  belongs_to :parent_comment, :class_name => 'Comment', :foreign_key => 'parent_id'
  has_many :child_comments, :class_name => 'Comment', :foreign_key => 'parent_id', :dependent => :nullify
  
  belongs_to :topic, :inverse_of => :comments
  has_many :votes, :as => :votable, :dependent => :destroy
  has_many :flags, :dependent => :destroy
  
  acts_as_enum :moderation_status, [:ok, :unchecked, :spam]
  
  scope :visible, where(:moderation_status => moderation_status(:ok))
  scope :requiring_moderation, where("moderation_status != ?", moderation_status(:ok))
  
  validates_presence_of :content
  #validates_presence_of :author_ip
  
  before_validation :nullify_blank_fields
  before_create :set_moderation_status
  after_create :update_topic_timestamp
  #after_create :create_author, :update_author, :notify_comment_subscribers
  after_create :redis_update
  after_destroy :redis_update

  scope :by_user, lambda{ |username, email| where('author_name =? AND author_email = ?', username, email).order('created_at DESC') }

  include Like

  def site
    topic.site
  end

  def author_email_md5
    if author_email
      Digest::MD5.hexdigest(author_email.downcase)
    else
      nil
    end
  end

   def total_flags_str
     return_str = ""
     flag_comments = flags.select{|flag| flag.author_email.present?}
     guest_votes = (flags.select{|flag| flag.author_email.blank?}.first.guest_count.to_i rescue 0)
     total_flags = flag_comments.size + guest_votes
     return_str = total_flags > 0 ? total_flags > 1 ? total_flags.to_s + " users flagged. " : total_flags.to_s + " user flagged. " : ""
     return return_str
   end

  def flagged
    return_str = ""
    flag_comments = flags.select{|flag| flag.author_email.present?}
    guest_votes = (flags.select{|flag| flag.author_email.blank?}.first.guest_count.to_i rescue 0)
    total_flags = flag_comments.size + guest_votes
    return_str = total_flags > 0 ? "Flagged" : "Flag"
    return return_str
  end
  
  def is_flagged?
    return (self.flag_status == 'Flagged' ? true : false)
  end
  
  def spam?
    response = call_akismet('comment-check', akismet_params)
    if response.body == 'invalid'
      if response['X-akismet-debug-help']
        message = "Akismet server error: " << response['X-akismet-debug-help']
      else
        message = "Unknown Akismet server error, maybe your API key is wrong"
      end
      raise AkismetError, message
    elsif response.body == 'true'
      true
    elsif response.body == 'false'
      false
    else
      raise AkismetError, "Akismet server error: #{response.body}"
    end
  end
  
  def report_ham
    call_akismet('submit-ham', akismet_params)
  end
  
  def report_spam
    call_akismet('submit-spam', akismet_params)
  end
  
  def can_edit?(username, user_email)
    return false if (!self.author_email.blank? and self.author_email != user_email)
    created_at > Time.zone.now - COMMENT_EDIT_DURATION
  end

  def report_comment_flag(params, request)
    if params[:author_name].blank? or params[:author_email].blank?
      # Report a flag to comment for guest user.
      flag_comments = self.flags.where(:author_name => nil).where(:author_email => nil)
      if flag_comments.present?
        flag_comments.first.add_flag
      else
        self.flags.create!(
          :author_ip => request.env['REMOTE_ADDR'],
          :author_user_agent => request.env['HTTP_USER_AGENT'],
          :referer => request.env['HTTP_REFERER'],
          :guest_count => 1)
      end
    else
      # Report a flag to comment if user logged in.
      flag_comments = self.flags.where(author_email:params[:author_email]).where(author_name:params[:author_name])
      unless flag_comments.present?
        self.flags.create!(
          :author_name => params[:author_name],
          :author_email => params[:author_email],
          :author_ip => request.env['REMOTE_ADDR'],
          :author_user_agent => request.env['HTTP_USER_AGENT'],
          :referer => request.env['HTTP_REFERER'])
      end
    end
  end

  def get_users_comment_like(vote_type)
    self.votes.user_liked.votes_by_type(vote_type)
  end
  
  def author
    Author.where(author_email: author_email).first
  end

  def permalink(url)
    url.blank? ? "#" : url + "#comment-box-#{self.comment_number}"
  end

  def create_author
    Author.create!(:author_email => author_email) unless author.present?
    notify_moderators if parent_comment.present? and parent_comment.author.present? and parent_comment.author.notify_me
  end
  
  def update_author
    author.update_author_last_posted_at if author.present?
  end

  def notify_moderators
    Mailer.comment_posted(parent_comment,self).deliver
  end

private
  AKISMET_HEADERS = {
    'User-Agent' => "Juvia | Rails/#{Rails.version}",
    'Content-Type' => 'application/x-www-form-urlencoded'
  }
  
  def nullify_blank_fields
    self.author_name  = nil if author_name.blank?
    self.author_email = nil if author_email.blank?
    self.author_user_agent = nil if author_user_agent.blank?
    self.referer = nil if referer.blank?
  end
  
  def akismet_params
    raise AkismetError, "Site URL required for Akismet check" if topic.site.url.blank?
    params = {
      :blog => topic.site.url,
      :user_ip => author_ip,
      :user_agent => author_user_agent,
      :referrer => referer,
      :comment_content => content,
      :comment_type => 'comment'
    }
    params[:comment_author] = author_name if author_name.present?
    params[:comment_author_email] = author_email if author_email.present?
    params
  end
  
  def call_akismet(function_name, params)
    raise AkismetError, "Akismet key required" if topic.site.akismet_key.blank?
    uri = URI.parse("http://#{topic.site.akismet_key}.rest.akismet.com/1.1/#{function_name}")
    post_data = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.post(uri.path, post_data, AKISMET_HEADERS)
    end
    if response.code != "200"
      raise AkismetError, "Akismet internal error #{response.code}"
    else
      response
    end
  end
  
  def set_moderation_status
    case topic.site.moderation_method
    when :akismet
      self.moderation_status = spam? ? :spam : :ok
    when :manual
      self.moderation_status = :unchecked
    else
      self.moderation_status = :ok
    end
  end

  def update_topic_timestamp
    if topic
      topic.update_attribute(:last_posted_at, Time.now)
    end
  end
  
  def self.last_comment_number(total_comments)
    total_comments.blank? ? 0 : (total_comments[0].comment_number.blank? ? 0 : (total_comments[0].comment_number) )
  end
  
  def redis_update
    $redis.set("#{self.topic.key.to_s}", self.topic.comments.size)
  end
  
  def self.topic_comment_count?(topic_key, count)
    $redis.get("#{topic_key.to_s}") == count
  end
  
  def topic_notification
    TopicNotification.where("topic_id=?", topic_id)
  end
  
  def notify_comment_subscribers
    topic_comments = topic_notification
    if topic_comments.present?
      topic_comments.each do |topic_comment|
        Mailer.delay.send_comment_notification_to_subscriber(self, topic_comment.author)
      end
    end
  end
end
