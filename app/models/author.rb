class Author < ActiveRecord::Base
  has_many :topic_notifications, :dependent => :destroy
  attr_accessible :author_email, :notify_me, :last_posted_at
  scope :get_user, lambda{ |email| where('author_email = ?', email) }
    
  def Author.notifier?(author_email)
    author = Author.where(author_email:author_email).first
    return author.present? ? author.notify_me : false
  end

  def update_author_last_posted_at
    self.last_posted_at = Time.zone.now
    self.save
  end

  def Author.can_post?(author_email)
    author = Author.get_user(author_email).first
    if author.present? and (Settings.juvia_comment.COMMENT_POST_DURATION.to_f.minutes > Time.zone.now - author.last_posted_at)
     return false
    else
     return true
    end
  end
  
  def self.lookup_or_create_author(author_email, notify_me)
    author = Author.get_user(author_email).first
    author = if author.present?
      author.notify_me = notify_me
      author
    else
      Author.new(notify_me:notify_me, author_email:params[:author_email])
    end
    author.save
    author
  end
end
