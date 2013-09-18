class TopicNotification < ActiveRecord::Base
  attr_accessible :author_id, :topic_id
  belongs_to :topic
  belongs_to :author
  scope :get_topic_notification, lambda{ |author_id, topic_id| where('author_id = ? and topic_id = ?', author_id, topic_id) }
  
  def self.lookup_or_create_topic_notification(author_id, topic_id)
    topic_notification = TopicNotification.get_topic_notification(author_id, topic_id).first
    topic_notification = TopicNotification.create!(topic_id:topic_id, author_id:author_id) if topic_notification.blank?
    topic_notification
  end
end
