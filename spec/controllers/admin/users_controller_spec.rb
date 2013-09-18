require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Admin::UsersController do
  def valid_attributes
    {:email => 'moderator@gmail.com',
     :password => 123456,
     :password_confirmation => 123456
     }
  end

  def create_site
    @site ||= FactoryGirl.create(:site1,:user =>admin)
  end

  def create_moderator
    @moderator ||= User.create! valid_attributes.merge(:roles_mask => 2)
  end

  def create_user
    @user = User.create! valid_attributes
  end

  before :each do
    sign_in(admin)
    create_site
  end

  it "creates a new user" do
    expect {
      post :create, :user => valid_attributes
    }.to change(User, :count).by(1)
  end

  it "assigns user to roles as moderator" do
    create_user
    post :update, :id => @user.id, :user => {:roles => [:site_moderator]}
  end

  it "admin can assign a site to moderator" do
    create_moderator
    put :assign_site, :id => @moderator.id, :site_id => @site.id.to_s
    @moderator.sites_as_moderator.first.id.should eq(@site.id)
  end

  it "admin can unassign a site to moderator" do
    create_moderator
    put :assign_site, :id => @moderator.id, :site_id => @site.id.to_s
    @moderator.sites_as_moderator.first.id.should eq(@site.id)
    delete :unassign_site, :id => @moderator.id, :site_id => @site.id.to_s
    @moderator.sites_as_moderator.first.should eq(nil)
  end
end
