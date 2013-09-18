require 'spec_helper'

describe "Comment" do

  before(:each) do
  	@topic = FactoryGirl.create(:topic, :site => hatsuneshima)
    @comment = FactoryGirl.create(:comment, :author_email => 'author@example.com', :author_name => 'author', :content => 'first post', :topic => @topic)
    @comment_user = FactoryGirl.create(:author, :author_email => 'author1@example.com', :notify_me => true)
  end

  it 'should check reply on comment' do
    @comment_reply = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author1', 
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment_reply.parent_comment.id.should eq(@comment_reply.parent_id)
  end

  it 'should have one reply' do
    @comment_reply = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author1', 
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment.child_comments.size.should eq(1)
  end

  it 'should have two replies' do
    @comment_reply1 = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author1', 
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment_reply2 = @topic.comments.create!(:author_ip => '127.0.0.2', :author_name => 'author2', 
                                             :author_email => 'author2@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment.child_comments.size.should eq(2)
  end
  
  it 'should send email to user after reply on comment' do
    @comment_reply = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author1', 
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment_user.notify_me.should eq(true)
    @comment_reply.create_author
  end
  
  it 'should delete parent comment' do
    @comment_reply = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author1',
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => @comment.id)
    @comment.destroy
    @comment_reply.reload.parent_id.should eq(nil)
  end

  it 'should post comment with some delay' do
    post_delay = Settings.juvia_comment.COMMENT_POST_DURATION.to_f.minutes
    @comment_user.update_attributes(:last_posted_at => @comment_user.last_posted_at - post_delay)
    comment1 = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author',
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => '')
    @comment_user.update_attributes(:last_posted_at => @comment_user.last_posted_at - post_delay)
    comment2 = @topic.comments.create!(:author_ip => '127.0.0.1', :author_name => 'author',
                                             :author_email => 'author1@example.com', :content => 'reply on comment', 
                                             :parent_id => '')
    @topic.comments.should include(comment1,comment2)
  end
end
