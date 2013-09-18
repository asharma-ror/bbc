class Api::VotesController < ApplicationController
  include ApplicationHelper
  layout nil
  
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  before_filter :populate_variables
  
  def posts_vote
    prepare!([:site_key, :topic_key, :comment_key, :topic_url, :vote], [:html, :js, :json])
    @comment = Topic.lookup(@site_key, @topic_key).comments.find(params[:comment_key])
    if params[:author_name].blank? or params[:author_email].blank?
      votes = @comment.guest_votes
      if votes.present?
        votes.first.add_like_unlike_vote(params[:vote])
      else
        vote = @comment.votes.build(:author_ip => request.env['REMOTE_ADDR'],
          :author_user_agent => request.env['HTTP_USER_AGENT'],
          :referer => request.env['HTTP_REFERER'])
        params[:vote] == "1" ? vote.like = 1 : vote.unlike = 1
        vote.save
      end
    else
      votes = @comment.votes.where(author_email:params[:author_email]).where(author_name:params[:author_name])
      if votes.present?
        votes.each{|vote| vote.destroy}
      else
        @comment.votes.create!(
          :author_name => params[:author_name],
          :author_email => params[:author_email],
          :author_ip => request.env['REMOTE_ADDR'],
          :author_user_agent => request.env['HTTP_USER_AGENT'],
          :referer => request.env['HTTP_REFERER'],
          :like => 1) unless (params[:author_email].eql?(@comment.author_email))
      end
    end
  end

  def topics_vote
    prepare!([:site_key, :topic_key, :topic_url, :vote], [:html, :js, :json])
    @topic = Topic.lookup_or_create(@site_key, @topic_key,params[:topic_title],params[:topic_url])
    if params[:author_name].blank? or params[:author_email].blank?
      votes = @topic.guest_votes
      if votes.present?
        votes.first.add_like_unlike_vote(params[:vote])
      else  
        vote = @topic.votes.build(:author_ip => request.env['REMOTE_ADDR'],
             :author_user_agent => request.env['HTTP_USER_AGENT'],
             :referer => request.env['HTTP_REFERER'])
        params[:vote] == "1" ? vote.like = 1 : vote.unlike = 1
        vote.save
      end
    else
      votes = @topic.votes.where(author_email:params[:author_email]).where(author_name:params[:author_name])
      if votes.present?
        votes.each{|vote| vote.destroy}
      else
        vote = @topic.votes.build(
            :author_name => params[:author_name],
            :author_email => params[:author_email],
            :author_ip => request.env['REMOTE_ADDR'],
            :author_user_agent => request.env['HTTP_USER_AGENT'],
            :referer => request.env['HTTP_REFERER'])
        params[:vote] == "1" ? vote.like = 1 : vote.unlike = 1
        vote.save
      end
    end
  end  
end
