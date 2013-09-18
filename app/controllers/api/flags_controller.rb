class Api::FlagsController < ApplicationController
  include ApplicationHelper
  layout nil
  
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  before_filter :handle_cors, :populate_variables


  def post_report
    prepare!([:site_key, :topic_key, :topic_url, :comment_key], [:html, :js, :json])
    @topic = Topic.lookup(@site_key, @topic_key)
    @comment = @topic.comments.find(params[:comment_key])
    @comment.report_comment_flag(params, request)
  end
end
