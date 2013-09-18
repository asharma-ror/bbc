require 'spec_helper'

describe "TopicNotification" do
  
  def create_new_topic
    admin = FactoryGirl.create(:admin)
    site  = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
    topic = FactoryGirl.create(:topic,:site_id => site.id)
  end
  
  after(:each) do
    TopicNotification.delete_all
  end
  
  it "should find or create topic notification" do
    create_new_topic
    author = FactoryGirl.create(:author, :author_email => 'user@mail.com', :notify_me => true)
    topic = Topic.last
    topic_notification = FactoryGirl.create(:topic_notification, :author_id => author.id, :topic_id => topic.id)
    topic_notification = TopicNotification.lookup_or_create_topic_notification(author.id, topic.id)
    topic_notification.topic_id.should == topic.id
    TopicNotification.delete_all
    expect {
      topic_notification = TopicNotification.lookup_or_create_topic_notification(author.id, topic.id)
    }.to change(TopicNotification, :count).by(1)
  end
end
