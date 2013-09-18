# -*- Mode: Ruby; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

require 'zlib'

class ApiController < ApplicationController

  include ApplicationHelper
  layout nil
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  before_filter :handle_cors, :populate_variables
  before_filter :check_restrict_comment_length, :only => [ :add_comment, :update_comment ]
 
  def user_comments
    prepare!([:site_key, :username, :user_email, :container],[:html, :js])
    @comments = Site.get_site(params[:site_key])[0].comments.by_user(params[:username], params[:user_email]).page(1).per(PER_PAGE)
  end 

  def append_user_comments
    prepare!([:site_key, :username, :user_email, :container],[:html, :js])
    @comments = Site.get_site(params[:site_key])[0].comments.by_user(params[:username], params[:user_email])
    .page(params[:page].to_i)
    .per(PER_PAGE)
  end 
  
  def comments_count
    prepare!([:site_key],[:html, :js])
    @comments_arr = []
    params.each do |key, value|
      if ( key == "0" or key.to_i > 0 ) and value.to_s.split(",").size > 1
        @comments_arr.push({
          "uid" => "#{key}",
          "comments" => "#{$redis.get("#{params[:site_key]}_#{value.to_s.split(",")[1]}").to_i}"
        })
      end
    end
    render
  end

  def list_topics
    prepare!([:site_key], [:json, :jsonp])
    @site = Site.find_by_key(@site_key)
    if @site
      render
    else
      render :partial => 'api/site_not_found'
    end
  end

  def topics_info
    prepare!([:site_key], [:html])
    site = Site.find_by_key(params[:site_key])
    if site
      render :json => site.topics_info
    else
      render :partial => 'api/site_not_found'
    end
  end

private
  def log_exception(e)
    logger.error("#{e.class} (#{e}):\n  " <<
      e.backtrace.join("\n  "))
  end
end
