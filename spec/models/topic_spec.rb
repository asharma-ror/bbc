require 'spec_helper'

describe "Topic" do

  before(:each) do
  	@topic = FactoryGirl.create(:topic, :site => hatsuneshima)
  	@topic2 = FactoryGirl.create(:topic, :site => site2)
    @comment1 = FactoryGirl.create(:comment, :content => 'first post', :topic => @topic, :created_at => Time.now - 10.day)
    @comment2 = FactoryGirl.create(:comment, :content => 'post', :topic => @topic, :created_at => Time.now - 9.day)
    @comment3 = FactoryGirl.create(:comment, :content => 'post', :topic => @topic, :created_at => Time.now - 8.day)
    @comment4 = FactoryGirl.create(:comment, :content => 'post', :topic => @topic, :created_at => Time.now - 7.day)
    @comment5 = FactoryGirl.create(:comment, :content => 'post', :topic => @topic, :created_at => Time.now - 6.day)
    @vote = FactoryGirl.create(:vote, :like => 1, :votable_id => @comment4.id, :votable_type => "Comment" )
    @site_key  = hatsuneshima.key
    @site_key2  = site2.key
    @topic_key = @topic.key
    @topic_key2 = @topic2.key
  end

  def vote_attributes
    FactoryGirl.build(:vote).attributes
  end
  
  it 'get newest comments' do
    @topic.topic_comments.newest.visible.to_a[0].should eql(@comment5)
  end

  it 'get oldest comments' do
    @topic.topic_comments.oldest.visible.to_a[0].should eql(@comment1)
  end

  it 'get popular comments' do
    @topic.topic_comments.most_popular.to_a[0].should eql(@comment4)
  end

  it 'should find the right topic' do
    topic = Topic.lookup(@site_key, @topic_key)
    topic.title.should == 'my topic'
    topic = Topic.lookup(@site_key2, @topic_key2)
    topic.title.should == 'my topic'
  end

  it 'should find the right topic or create it' do
    topic = Topic.lookup_or_create(@site_key, @topic_key, @topic.title, @topic.url)
    topic.title.should == @topic.title
    topic = Topic.lookup_or_create(@site_key, '232435', 'my topic title', 'my topic url')
    topic.title.should == 'my topic title'
    topic = Topic.lookup_or_create('45454', '232435', 'my topic title', 'my topic url')
    topic.should == nil
  end

  it 'get users who likes the topic' do
    topic = Topic.lookup(@site_key, @topic_key)
    user1_vote = topic.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name1",
  		:author_email=>"author_name1@email.com"})
    user2_vote = topic.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name2",
  		:author_email=>"author_name2@email.com"})
    guest_user_vote = topic.votes.create vote_attributes.merge({:like => 1})
    topic.get_users_topic_like("Topic").count.should eql(2)
    topic.get_users_topic_like("bad_vote_type").count.should eql(0)
    topic.get_users_topic_like("Topic")[0].author_email == user1_vote.author_email
    topic.get_users_topic_like("Topic")[1].author_email == user2_vote.author_email
  end
end
