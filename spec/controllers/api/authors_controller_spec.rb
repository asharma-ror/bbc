require 'spec_helper'

describe Api::AuthorsController do
  
  def create_required_objects
    @admin = FactoryGirl.create(:admin)
    @site  = FactoryGirl.create(:hatsuneshima, :user_id => @admin.id)
    @topic = FactoryGirl.create(:topic,:site_id => @site.id)
    @author = FactoryGirl.create(:author, :author_email => 'user@mail.com', :notify_me => "1")
  end
  
  after(:all) do
    @admin.destroy
    @site.destroy
    @topic.destroy
    @author.destroy
  end
    
  describe "GET update_topic_notification" do
    
    it "should create topic notification with all valid values" do
      create_required_objects
      expect {
        get :update_topic_notification, get_params
      }.to change(TopicNotification, :count).by(1)
      response.should be_true
    end
    
    it "should not create topic notification when params parameters are missing" do
      create_required_objects
      expect {
        get :update_topic_notification, get_params(:author_email => "")
      }.to change(TopicNotification, :count).by(0)
    end
  end
  
  describe "GET delete_topic_notification" do
    before(:each) do
      create_required_objects
      @topic_notification = FactoryGirl.create(:topic_notification, :author_id => @author.id, :topic_id => @topic.id)
    end
    
    after(:each) do
      @topic_notification.destroy
    end
    
    it "should delete topic notification with all valid values" do
      expect {
        get :destroy_topic_notification, get_params
      }.to change(TopicNotification, :count).by(-1)
      response.should be_true
    end
    
    it "should not delete topic notification when params parameters are missing" do
      expect {
        get :destroy_topic_notification, get_params(:author_email => "")
      }.to change(TopicNotification, :count).by(0)
    end
  end
  
  def get_params(options = {})
    {
      :author_email => @author.author_email,
      :notify_me => "0", 
      :site_key => @site.key, 
      :topic_key => @topic.key, 
      :topic_title => @topic.title, 
      :topic_url => @topic.url, 
      :format => 'js'
    }.merge(options)
  end
end
