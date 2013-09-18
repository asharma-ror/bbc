module Admin

class UsersController < ApplicationController
  layout 'admin'
  
  load_and_authorize_resource
  
  skip_authorization_check :only => [:index, :edit]
  before_filter :set_navigation_ids
  
  def index
    if !can?(:list, User)
      redirect_to dashboard_path
      return
    end

    @users = User.order('email').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  def show
    @sites = (@user.admin?) ? Site.all : @user.sites_as_moderator
    @topics   = @user.topics
    
    respond_to do |format|
      format.html
      format.json { render :json => @user }
    end
  end
  
  def new
  end

  def edit
    redirect_to admin_user_path(params[:id])
  end

  def create
    @user = User.new(params[:user], :as => current_user.role)

    respond_to do |format|
      if @user.save
        format.html { redirect_to(admin_users_path, :notice => 'User was successfully created.') }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user], :as => current_user.role)
        format.html { redirect_to(admin_users_path, :notice => 'User was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "show" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    # @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_path) }
      format.json { head :ok }
    end
  end

  def assign_site
    @site_moderator = @user.site_moderators.create(:site_id => params[:site_id])
    redirect_to(show_site_admin_user_path(@user))
  end

  def show_site
    @sites = @user.sites_as_moderator
  end

  def unassign_site
    @site_moderator = @user.site_moderators.where(:site_id => params[:site_id]).first
    @site_moderator.destroy unless @site_moderator.blank?
    redirect_to(show_site_admin_user_path(@user))
  end

private
  def set_navigation_ids
    @navigation_ids = [:dashboard, :users]
  end
end

end # module Admin
