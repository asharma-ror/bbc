require 'zlib'

class Api::CommentsController < ApplicationController
  include ApplicationHelper
  layout nil
  
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  before_filter :handle_cors, :populate_variables
  before_filter :check_restrict_comment_length, :only => [ :add_comment, :update_comment ]

  def show_topic
    @user_image, @username = params[:user_image], params[:username]
    @include_base, @include_css = get_boolean_param(:include_base, true), get_boolean_param(:include_css, true)
    prepare!([:site_key, :topic_key, :container], [:html, :js])
    @topic = Topic.lookup(@site_key, @topic_key)
    topic_url_arr = params[:topic_url].split('#')
    @perma_link_comment_id = topic_url_arr[1].blank? ? nil : topic_url_arr[1].split('-')[2]
    if @topic
      @notify_on = Author.notifier?(@user_email) if @require_external_user and @user_logged_in
      render 
    else
      render :partial => 'api/site_not_found'
    end
  end

  def load_comments
    prepare!([:site_key, :topic_key], [:html, :js])
    @topic = Topic.lookup_or_create(@site_key, @topic_key)
    topic_comments = @topic.topic_comments
    comments = topic_comments.send("oldest")
    @last_comment_number = @topic.last_comment_number
    @chats = Kaminari.paginate_array(comments)
    @chat_count = topic_comments.size
  end
  
  def touch_chat
    prepare!([:topic_key, :comment_count], [:js, :json])
    @comment_status = Comment.topic_comment_count?(params[:topic_key], params[:comment_count])
  end
  
  def append_chat
    prepare!([:topic_key, :comment_number], [:js, :json])
    @topic = Topic.where(:key => params[:topic_key].to_s).first
    @chats = @topic.new_comments(params[:comment_number])
    @last_comment_number = @topic.last_comment_number
    topic_comments = @topic.topic_comments
    @chat_count = topic_comments.size
  end

  def add_comment
    prepare!([:site_key, :topic_key, :content], [:html, :js, :json])
    if @content.blank?
      render :partial => 'content_may_not_be_blank'
      return
    end
    comment_post_ability!(params[:author_email])
    
    Topic.transaction do
      @topic = Topic.lookup_or_create(
        @site_key,
        @topic_key,
        params[:topic_title],
        params[:topic_url])
      if @topic
        parent_id = (Comment.where(id:params[:parent_id]).first.present?) ? params[:parent_id] : nil
        @comment = @topic.comments.create!(
          :comment_number => Comment.last_comment_number(@topic.comments) + 1,
          :author_name => params[:author_name],
          :author_email => params[:author_email],
          :author_ip => request.env['REMOTE_ADDR'],
          :author_user_agent => request.env['HTTP_USER_AGENT'],
          :referer => request.env['HTTP_REFERER'],
          :content => @content,
          :parent_id => parent_id)
        @last_comment_number = @topic.last_comment_number
        topic_comments = @topic.topic_comments
        @chat_count = topic_comments.size
      else
        render :partial => 'api/site_not_found'
      end
    end
  end
  
  def show_comments
    prepare!([:site_key, :topic_key, :topic_url, :sorting_order, :page],[:html, :js])
    list_comments
  end

  def update_comment
    prepare!([:site_key, :content, :comment_id], [:js, :json])
    if @content.blank?
      render :partial => 'content_may_not_be_blank'
      return
    end
    @site = Site.find_by_key(@site_key)
    @comment = Comment.find(params[:comment_id])
    if @comment.update_attributes(
      :author_ip => request.env['REMOTE_ADDR'],
      :author_user_agent => request.env['HTTP_USER_AGENT'],
      :referer => request.env['HTTP_REFERER'],
      :content => @content)
      render
    else
      render :partial => 'api/site_not_found'
    end
  end

  def destroy
    prepare!([:site_key, :comment_key, :user_email], [:js, :json])
    @comment = Comment.find(params[:comment_key])
    if !@comment.blank? and (@comment.author_email == params[:user_email]) 
      @comment.destroy
      render
    else
      render :partial => 'api/site_not_found'
    end

  end

  def sort_comment
    @username = params[:author_name]
    @user_email = params[:author_email]
    prepare!([:site_key, :topic_key, :topic_url, :topic_title, :sort], [:html, :js, :json])
    @topic = Topic.lookup(@site_key, @topic_key)
    if @topic
      @comments = order_by_params(params[:sort]).page(params[:page] || 1).per(PER_PAGE)
      render
    else
      render :partial => 'api/site_not_found'
    end
  end

  def show_like_users
    prepare!([:site_key, :topic_key], [:html, :js, :json])
    @comment = Topic.lookup(@site_key, @topic_key).comments.find(params[:comment_key])
    @votes = @comment.get_users_comment_like("Comment")
  end

  def show_topic_like_users
    prepare!([:site_key, :topic_key], [:html, :js, :json])
    @topic_votes = Topic.lookup(@site_key, @topic_key).get_users_topic_like("Topic")
  end

private
  def get_boolean_param(name, default = false)
    if params[name].present?
      value = params[name].downcase
      value == 'true' || value == 'yes' || value == '1' || value == 'on'
    else
      default
    end
  end
  
  def decompress(str)
    return str #if Rails.env.test?
    result = Zlib::Inflate.inflate(str.unpack('m').first)
    result.force_encoding('utf-8') if result.respond_to?(:force_encoding)
    result
  end

  def check_restrict_comment_length
    @content = if params["restrict_comment_length"] == "true"
      decompress(params[:content]).to_s[0..139]
    else
      decompress(params[:content]).to_s
    end
    @content = view_context.strip_tags @content
  end 

  def list_comments(perma_link_comment_id = "")
    @topic = Topic.lookup(@site_key, @topic_key)
    @perma_link_comment = perma_link_comment_id.blank? ? nil : @topic.comments.where(comment_number:perma_link_comment_id).first
    if @topic
      @comments = order_by_params(params[:sorting_order]).page(params[:page] || 1).per(PER_PAGE)
      render
    else
      render :partial => 'api/site_not_found'
    end
  end
  
  def order_by_params sort_order
    case sort_order
      when "oldest"
        comments = @topic.topic_comments.send("oldest")
      when "newest"
        comments = @topic.topic_comments.send("newest")
      when "most_popular"
        comments = @topic.topic_comments.send("most_popular")
      else
        comments = @topic.topic_comments.send("oldest")
    end
    Kaminari.paginate_array(comments.visible)
  end
  
end
