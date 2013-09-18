class Admin::TopicsController < InheritedResources::Base
  layout 'admin'

  load_and_authorize_resource
  before_filter :set_navigation_ids, :expect => [:show, :index]
  before_filter :set_topic_navi, :only => [:show, :index]

  def show
    show! do
      @site = Site.find(params[:site_id])
      @comments = @topic.comments.page(params[:page])
    end
  end

  def destroy    
    destroy! do
      redirect_to admin_site_topics_path and return
    end
  end

  def index
    authorize! :read, Site
    @sites = Site.accessible_by(current_ability, :read).order('created_at ASC')
    redirect_to admin_sites_path , notice: "There are no sites available" and return if @sites.blank?
    @site = if( !params[:site_id].blank? )
      @sites.where( :id => params[:site_id])[0]
    else
      @sites[0]
    end
    total_topics = @site.topics.order("last_posted_at desc")
    no_comment_topics = total_topics.select{|topic| topic.comments.size == 0}
    total_topics.reject!{|topic| topic.comments.size == 0}
    @topics = Kaminari.paginate_array(total_topics + no_comment_topics).page(params[:page])
    redirect_to admin_sites_path, warning: "There are no site available" and return if @site.blank?
  end

  def new
    raise "Not allowed"
  end

  def create
    raise "Not allowed"
  end

  def edit
    raise "Not allowed"
  end

  def update
    raise "Not allowed"
  end

  def open_close_commenting
    topic = Topic.find(params[:id])
    topic.update_attribute(:comments_open, !topic.comments_open)
    redirect_to(:back) and return
  end

private
  def set_navigation_ids
    @navigation_ids = [:dashboard, :sites]
  end
  
  def set_topic_navi
    @navigation_ids = [:dashboard, :topics]
  end
end
