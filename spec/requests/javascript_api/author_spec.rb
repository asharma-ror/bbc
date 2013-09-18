require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")
require 'zlib'
describe "Javascript API", "error handling" do
  describe "author" do
    
    def create_new_topic
      admin = FactoryGirl.create(:admin)
      site  = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      topic = FactoryGirl.create(:topic,:site_id => site.id)
    end
    
    def show_topic(site_key, topic_key, options = {})
      super(site_key, topic_key, options.merge(
        :pre_js => %Q{
          var Juvia = { supportsCors: false };
        })
      )
    end
    
    describe "js format" do
      describe "author" do      
        it "should on email notification " , :js => true do
          Author.delete_all
          create_new_topic
          topic = Topic.last
          show_topic(topic.site.key, topic.key)
          find("#juvia-setting").click
          find("#juvia-author-setting").text.should include("Email Notification is OFF")
          find("#author_email_setting").click
          find("#juvia-setting").click
          find("#juvia-author-setting").text.should include("Email Notification is ON")
          within(".juvia_email_notification") do
              find(".alert").text.should include("Email notifications were successfully saved.")
          end
        end
        
        it "should off email notification " , :js => true do
          create_new_topic
          author = FactoryGirl.create(:author, :author_email => 'user@mail.com', :notify_me => true)
          topic = Topic.last
          show_topic(topic.site.key, topic.key)
          find("#juvia-setting").click
          find("#juvia-author-setting").text.should include("Email Notification is ON")
          find("#author_email_setting").click
          
          find("#juvia-setting").click
          find("#juvia-author-setting").text.should include("Email Notification is OFF")
          
          within(".juvia_email_notification") do
              find(".alert").text.should include("Email notifications were successfully saved.")
          end
        end
        
        it "should on email notificaiton on topic" , :js => true do
          create_new_topic
          topic = Topic.last
          author = FactoryGirl.create(:author, :author_email => 'user@mail.com', :notify_me => true)
          topic_notification = FactoryGirl.create(:topic_notification, :author_id => author.id, :topic_id => topic.id)
          show_topic(topic.site.key, topic.key)
          find("#subscriber_email").text.should include("Notified this topic")
          find("#subscriber_email").click
          within(".juvia_email_notification") do
            find(".alert").text.should include("Email notifications were successfully saved.")
          end
        end
        
        it "should off email notificaiton on topic" , :js => true do
          create_new_topic
          topic = Topic.last
          show_topic(topic.site.key, topic.key)
          find("#subscriber_email").text.should include("Notification about this topic")
        end
      end
    end
  end  
end
