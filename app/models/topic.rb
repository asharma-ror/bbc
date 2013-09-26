class Topic < ActiveRecord::Base
  attr_accessible :site_id, :key, :title, :url, :last_posted_at, :vote_counts, :votes_value
  belongs_to :site, :inverse_of => :topics
  has_many :comments, :order =>'created_at DESC', :inverse_of => :topic, :dependent => :destroy
  has_many :votes, :as => :votable, :dependent => :destroy
  has_many :topic_notifications, :dependent => :destroy
  has_many :topic_comments, :class_name => "Comment", :include => "votes" do
  
    def oldest
      order(:created_at)
    end

    def newest
      order("created_at DESC")
    end

    def most_popular
      order("votes_value DESC NULLS LAST")
    end
  end

  validates :key, :presence => true, :uniqueness => true
  #validates_presence_of :key
  #validates_presence_of :title
  #validates_presence_of :site_id
  #validates_presence_of :url

  include Like  

  def new_comments(comment_number)
    topic_comments.where("comment_number > ? ", comment_number.to_i)
  end

  def last_comment_number
    total_comments = topic_comments.newest
    total_comments.blank? ? 0 : (total_comments[0].comment_number.blank? ? 0 : (total_comments[0].comment_number) )
  end

  def self.topic_comments_size(topic_id, site_key)
    if topic = Topic.find_by_site_key_and_topic_key(site_key, topic_id)
      topic.comments.size
    else 
      return 0
    end
  end

  def self.lookup(site_key, topic_key)
    topic = find_by_key(topic_key)
    if topic
      topic
    else
      site = Site.first
      if site
        Topic.new(:key => topic_key, :site => site)
      else
        nil
      end
    end
  end
  
  def self.lookup_or_create(site_key, topic_key, topic_title = "" , topic_url = "")
    topic = find_by_key(topic_key)
    if topic
      topic
    else
      site = Site.first
      if site
        site.topics.create!(
          :key => topic_key,
          :title => topic_title,
          :url => topic_url)
      else
        nil
      end
    end
  end
  
  def last_comment
    self.comments.order("created_at desc").limit(1).first
  end

  def last_commented_at
    self.last_comment.created_at rescue nil
  end

  def get_users_topic_like(vote_type)
    self.votes.user_liked.votes_by_type(vote_type)
  end

private

  def self.find_by_site_key_and_topic_key(site_key, topic_key)
    Topic.where(:site_id => Site.find_by_key(site_key).id).where(:key => topic_key).first rescue nil
  end

end
