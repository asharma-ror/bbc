require 'spec_helper'

describe "Vote" do

  before(:each) do
  	@topic = FactoryGirl.create(:topic, :site => hatsuneshima)
    @comment = FactoryGirl.create(:comment, :content => 'first post', :topic => @topic)
    @site_key  = hatsuneshima.key
    @topic_key = @topic.key
  end

  def vote_attributes
    FactoryGirl.build(:vote).attributes
  end

  it 'Reference is required Vote' do
  	vote = Vote.new vote_attributes
    vote.valid?.should be_false
  end

  it 'Vote (like/unlike) is required' do
  	vote = @topic.votes.create vote_attributes
    vote.valid?.should be_false
  end

  it 'Vote (like/unlike) is required' do
  	vote = @comment.votes.create vote_attributes
    vote.valid?.should be_false
  end

  it 'Topic\'s Vote(like) has been saved successfully' do
    vote = @topic.votes.create vote_attributes.merge({:like => 1})
    vote.should eq(Vote.first)
  end
  
  it 'Topic\'s Vote(unlike) has been saved successfully' do
    vote = @topic.votes.create vote_attributes.merge({:unlike => 1})
    vote.should eq(Vote.first)
  end

  it 'Comments Vote(like) has been saved successfully' do
    vote = @comment.votes.create vote_attributes.merge({:like => 1})
    vote.should eq(Vote.first)
  end

  it 'Topic: One guest liked this.' do
  	vote = @topic.votes.create vote_attributes.merge({:like => 1})
    @topic = vote.votable
  	@topic.users_and_guests_likes_string.should eql("One guest liked this.")
  	@topic.vote_counts.should eql("One guest liked this.")
  end
  
  it 'Topic: One guest unliked this.' do
  	vote = @topic.votes.create vote_attributes.merge({:unlike => 1})
    @topic = vote.votable
  	@topic.users_and_guests_likes_string.should eql("")
  	@topic.vote_counts.should eql("")
  end

  it 'Comment: message users_and_guests_likes_string' do
  	vote = @comment.votes.create vote_attributes.merge({:like => 1})
    @comment = vote.votable
  	@comment.users_and_guests_likes_string.should eql("One guest liked this.")
  	@comment.vote_counts.should eql("One guest liked this.")
    @comment.total_likes_value.should eq(1)
    @comment.votes_value.should eq(1)
  end
  
  it 'Comment: message users_and_guests_likes_string' do
  	vote = @comment.votes.create vote_attributes.merge({:unlike => 1})
    @comment = vote.votable
  	@comment.users_and_guests_likes_string.should eql("")
  	@comment.vote_counts.should eql("")
    @comment.total_likes_value.should eq(0)
    @comment.votes_value.should eq(0)
  end

  it 'Topic: User and guest liked this.' do
  	vote = @topic.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
  	@topic.users_and_guests_likes_string.should eql("One user liked this.")
  	vote.votable.vote_counts.should eql("One user liked this.")
    @topic.total_likes_value.should eq(2)
    vote.votable.votes_value.should eq(2)

    vote = @topic.votes.create vote_attributes.merge({:like => 1})
    @topic.users_and_guests_likes_string.should eql("One user and One guest liked this.")
    vote.votable.vote_counts.should eql("One user and One guest liked this.")
    @topic.total_likes_value.should eq(3)
    vote.votable.votes_value.should eq(3)

    vote = @topic.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
    @topic.users_and_guests_likes_string.should eql("2 users and One guest liked this.")
    vote.votable.vote_counts.should eql("2 users and One guest liked this.")
    @topic.total_likes_value.should eq(5)
    vote.votable.votes_value.should eq(5)
  end

  it 'Comment: User and guest liked this.' do
  	vote = @comment.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
  	@comment.users_and_guests_likes_string.should eql("One user liked this.")
  	vote.votable.vote_counts.should eql("One user liked this.")
    @comment.total_likes_value.should eq(2)
    vote.votable.votes_value.should eq(2)

  	vote = @comment.votes.create vote_attributes.merge({:like => 1})
  	@comment.users_and_guests_likes_string.should eql("One user and One guest liked this.")
  	vote.votable.vote_counts.should eql("One user and One guest liked this.")
    @comment.total_likes_value.should eq(3)
    vote.votable.votes_value.should eq(3)

  	vote = @comment.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
  	@comment.users_and_guests_likes_string.should eql("2 users and One guest liked this.")
  	vote.votable.vote_counts.should eql("2 users and One guest liked this.")    
    @comment.total_likes_value.should eq(5)
    vote.votable.votes_value.should eq(5)
  end
  
  it 'get user\'s who likes comment' do
    user_vote1 = @comment.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name1",
  		:author_email=>"author_name1@email.com"})
    user_vote2 = @comment.votes.create vote_attributes.merge({:like => 1, 
  		:author_name=>"author_name2",
  		:author_email=>"author_name2@email.com"})
    @comment.get_users_comment_like("Comment").count.should eql(2)
    @comment.get_users_comment_like("bad_vote_type").count.should eql(0)
    @comment.get_users_comment_like("Comment")[0].author_email == user_vote1.author_email
    @comment.get_users_comment_like("Comment")[1].author_email == user_vote2.author_email
  end
end
