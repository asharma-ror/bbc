class Admin::CommentsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  skip_authorization_check :only => [:preview]

  before_filter :set_navigation_ids
  before_filter :save_return_to_url, :only => [:new, :edit, :approve, :destroy]
  
  def index
    authorize! :read, Comment
    @sites = Site.accessible_by(current_ability, :read).order('created_at ASC') 
    redirect_to admin_sites_path , notice: "There are no sites available" and return if @sites.blank?
    @site = if( !params[:site_id].blank? )
      @sites.where( :id => params[:site_id])[0]
    else
      @sites[0]
    end
    redirect_to admin_sites_path, warning: "There are no site available" and return if @site.blank?
  end
  
  def edit
    @site = Site.find(params[:site_id])
    @comment = Comment.find(params[:id])
    authorize! :update, @comment
  end
  
  def update
    @comment = Comment.find(params[:id])
    authorize! :update, @comment
    if @comment.update_attributes(params[:comment])
      redirect_back(admin_site_comments_path)
    else
      render :action => 'edit'
    end
  end
  
  def preview
    render :text => ApplicationHelper.render_markdown(params[:content])
  end

  def approve
    @comment = Comment.find(params[:id])
    authorize! :update, @comment
    @comment.transaction do
      @comment.moderation_status = :ok
      if @comment.site.moderation_method == :akismet
        @comment.report_ham
      end
      @comment.save!
    end
    redirect_back(admin_site_comments_path)
  end

  def destroy
    @comment = Comment.find(params[:id])
    authorize! :destroy, @comment
    @comment.transaction do
      if params[:spam] && @comment.site.moderation_method == :akismet
        @comment.report_spam
      end
      @comment.destroy
    end
    redirect_back(admin_site_comments_path)
  end

  def flags
    @sites = Site.accessible_by(current_ability, :read).order('created_at ASC') 
    redirect_to admin_sites_path , notice: "There are no sites available" and return if @sites.blank?
    @site = if( !params[:site_id].blank? )
      @sites.where( :id => params[:site_id])[0]
    else
      @sites[0]
    end
    redirect_to admin_sites_path, warning: "There are no site available" and return if @site.blank?
    @sites_comment = @site.comments
    comments = @sites_comment.where(:id => [Flag.latest.select(:comment_id).map { |e| e.comment_id }.uniq]).sort { |x, y| x.flags.size <=> y.flags.size }.reverse
    @flagcomments, flagcomment = [], Struct.new(:flaggers, :comment)
    comments.each do |comment|
      @flagcomments << flagcomment.new(comment.total_flags_str, comment)
    end
  end

  def destroy_flag
    comment = Comment.find(params[:id])
    comment.flags.each do |flag|
      authorize! :destroy, flag
      flag.destroy
    end
    redirect_back(flags_admin_site_comments_path)
  end

  def destroy_comments_by_author
    authorize! :destroy, Comment
    @site = Site.find(params[:site_id])
    comments = @site.comments.where(:author_email => params[:author_email]) unless @site.blank?
    comments.each do |comment|
      comment.destroy
    end
    redirect_to admin_site_comments_path
  end
  
private
  def set_navigation_ids
    @navigation_ids = [:dashboard, :comments]
  end
end
