class Api::AuthorsController < ApplicationController
  include ApplicationHelper
  layout nil
  
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  before_filter :handle_cors, :populate_variables

  def update_author
    prepare!([:author_email, :notify_me], [:js])
    author = Author.where(author_email:params[:author_email]).first
    notify_me = params[:notify_me] == "1" ? true : false
    
    @author = if author.present?
      author.notify_me = notify_me
      author
    else
      Author.new(notify_me:notify_me, author_email:params[:author_email])
    end
    @author.save
    render
  end
  
  def update_topic_notification
    prepare!([:author_email, :notify_me], [:js])
    @author = Author.lookup_or_create_author(params[:author_email], params[:notify_me])
    @topic = Topic.lookup_or_create(params[:site_key], params[:topic_key], params[:topic_title], params[:topic_url])
    @topic_notification = TopicNotification.lookup_or_create_topic_notification(@author.id, @topic.id) if @topic.present?
  end
  
  def destroy_topic_notification
    prepare!([:author_email, :notify_me], [:js])
    author = Author.lookup_or_create_author(params[:author_email], params[:notify_me])
    topic = Topic.lookup_or_create(params[:site_key], params[:topic_key], params[:topic_title], params[:topic_url])
    @topic_notification = TopicNotification.get_topic_notification(author.id, topic.id).first if topic.present?
    @topic_notification.destroy if @topic_notification.present?
  end
end
