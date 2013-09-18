require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

$commentor_remote_ip = 1

describe "Javascript API", "error handling" do
  describe "topics_vote" do

    def create_new_comment
      admin = FactoryGirl.create(:admin)
      site = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      topic = FactoryGirl.create(:topic,:site_id => site.id)
      comment = FactoryGirl.create(:comment,:topic_id => topic.id)
    end
    
    def get_comment_liked_users(path,comment,site,topic)
      comment_user_hash=Hash.new
      comment_user_hash.merge!(:comment_key => comment.id)
      comment_user_hash.merge!(:site_key => site.key)
      comment_user_hash.merge!(:topic_key => topic.key)      
      post path,comment_user_hash
    end    

    def post_comment_vote(path,author_name,author_email,vote,site,topic,comment)
      post_comment_hash=Hash.new
      post_comment_hash.merge!(:site_key => site.key)
      post_comment_hash.merge!(:topic_key => topic.key)
      post_comment_hash.merge!(:topic_url => topic.url)
      post_comment_hash.merge!(:comment_key => comment.id)
      post_comment_hash.merge!(:vote => vote)
      post_comment_hash.merge!(:author_name => author_name) unless author_name.blank?
      post_comment_hash.merge!(:author_email => author_email) unless author_email.blank?
      post path,post_comment_hash
    end
    
    def post_comment_vote_with_missing_arg(path,author_name,author_email,vote,site,topic,comment,missing_arg)
      post_comment_hash=Hash.new
      post_comment_hash.merge!(:site_key => site.key) if missing_arg != :site_key
      post_comment_hash.merge!(:topic_key => topic.key) if missing_arg != :topic_key
      post_comment_hash.merge!(:topic_url => topic.url) if missing_arg != :topic_url
      post_comment_hash.merge!(:comment_key => comment.id) if missing_arg != :comment_key
      post_comment_hash.merge!(:vote => vote) if missing_arg != :vote
      post_comment_hash.merge!(:author_name => author_name) unless author_name.blank?
      post_comment_hash.merge!(:author_email => author_email) unless author_email.blank?
      post path,post_comment_hash
    end

    describe "js format" do
      describe "guest like" do
        it "first time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("One guest liked this")
        end
        it "second time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("One guest liked this")
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("2 guests liked this")
        end
        it "third time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 guests liked this")
        end
      end
      describe "guest unlike" do
        it "first time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should include("2 guests liked this")
        end
        it "second time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should include("One guest liked this")
        end
        it "third time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should_not include("liked this")
        end
      end
      describe "user like" do
        it "first time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("One user liked this")
        end
        it "second time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("2 users liked this")
        end
        it "third time like" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users liked this")
        end
        it "same user like mutipal times" do
          create_new_comment
          comment=Comment.last
          2.times do |n|
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          end
          5.times do |n|
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          end
          response.body.should include("One user liked this")
        end

      end
      describe "user unlike" do
        it "first time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          response.body.should include("2 users liked this")
        end
        it "second time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',0,comment.topic.site,comment.topic,comment)

          response.body.should include("One user liked this")
        end
        it "third time unlike" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',0,comment.topic.site,comment.topic,comment)

          response.body.should_not include("liked this")
        end
        it "same user unlike mutipal times", :focus => true do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          2.times do |n|
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          end
          response.body.should include("3 users liked this")
          5.times do |n|
            post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',0,comment.topic.site,comment.topic,comment)
          end
          response.body.should include("2 users liked this")
        end
      end
      describe "both guest and user like" do
        it "After 3 user liked, first time like guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and One guest liked this.")
        end
        it "After 3 user liked, second time like guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and 2 guests liked this.")
        end
        it "After 3 user liked, third time like guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and 3 guests liked this.")        
        end
        it "After 3 guest liked, first time like user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("One user and 3 guests liked this.")
        end
        it "After 3 guest liked, second time like user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("2 users and 3 guests liked this.")
        end
        it "After 3 guest liked, third time like user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and 3 guests liked this.")
        end
      end
      describe "both guest and user unlike" do
        before(:each) do
        end
        
        it "After 3 users and 3 guests liked, first time unlike guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and 2 guests liked this.")
        end
        it "After 3 users and 3 guests liked, second time unlike guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users and One guest liked this.")
        end
        it "After 3 users and 3 guests liked, third time unlike guest" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
          response.body.should include("3 users liked this.")
        end
        it "After 3 users and 3 guests liked, first time unlike user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          response.body.should include("2 users and 3 guests liked this.")
        end
        it "After 3 users and 3 guests liked, second time unlike user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',0,comment.topic.site,comment.topic,comment)
          response.body.should include("One user and 3 guests liked this.")
        end
        it "After 3 users and 3 guests liked, third time unlike user" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',1,comment.topic.site,comment.topic,comment)

          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',0,comment.topic.site,comment.topic,comment)
          post_comment_vote('/api/post/vote.js','author_name3','author_name3@email.com',0,comment.topic.site,comment.topic,comment)
          response.body.should include("3 guests liked this.")
        end
      end
      
      describe "missing arguments" do
        describe "guest like" do
          it "if site_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment,:site_key)
            comment.votes.sum(:like).should eq(0)
          end
          it "if topic_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment,:topic_key)
            comment.votes.sum(:like).should eq(0)
          end
          it "if topic_url is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment,:topic_url)
            comment.votes.sum(:like).should eq(0)
          end
          it "if vote is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment,:vote)
            comment.votes.sum(:like).should eq(0)
          end
          it "if comment_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment,:comment_key)
            comment.votes.sum(:like).should eq(0)
          end
        end

        describe "guest unlike" do
          it "if site_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
            post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment,:site_key)
            comment.votes.sum(:like).should eq(1)
          end
          it "if topic_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
            post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment,:topic_key)
            comment.votes.sum(:like).should eq(1)
          end
          it "if topic_url is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
            post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment,:topic_url)
            comment.votes.sum(:like).should eq(1)
          end
          it "if vote is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
            post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment,:vote)
            comment.votes.sum(:like).should eq(1)
          end
          it "if comment_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js',nil,nil,1,comment.topic.site,comment.topic,comment)
            post_comment_vote('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js',nil,nil,0,comment.topic.site,comment.topic,comment,:comment_key)
            comment.votes.sum(:like).should eq(1)
          end
        end

        describe "user like" do
          it "if site_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment,:site_key)
            comment.votes.sum(:like).should eq(0)
          end
          it "if topic_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment,:topic_key)
            comment.votes.sum(:like).should eq(0)
          end
          it "if topic_url is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment,:topic_url)
            comment.votes.sum(:like).should eq(0)
          end
          it "if vote is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment,:vote)
            comment.votes.sum(:like).should eq(0)
          end
          it "if comment_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment,:comment_key)
            comment.votes.sum(:like).should eq(0)
          end
        end

        describe "user unlike" do
          it "if site_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment,:site_key)
            comment.votes.sum(:like).should eq(1)
          end
          it "if topic_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment,:topic_key)
            comment.votes.sum(:like).should eq(1)
          end
          it "if topic_url is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment,:topic_url)
            comment.votes.sum(:like).should eq(1)
          end
          it "if vote is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment,:vote)
            comment.votes.sum(:like).should eq(1)
          end
          it "if comment_key is missing then vote not created" do
            create_new_comment
            comment=Comment.last
            post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
            comment.votes.sum(:like).should eq(1)
            post_comment_vote_with_missing_arg('/api/post/vote.js','author_name1','author_name1@email.com',0,comment.topic.site,comment.topic,comment,:comment_key)
            comment.votes.sum(:like).should eq(1)
          end
        end

      end  
      describe "user like to topic comments" do
        it "should display users who liked topic\'s each comment" do
          create_new_comment
          comment=Comment.last
          post_comment_vote('/api/post/vote.js','author_name1','author_name1@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("One user liked this")
          post_comment_vote('/api/post/vote.js','author_name2','author_name2@email.com',1,comment.topic.site,comment.topic,comment)
          response.body.should include("2 users liked this")
          
          get_comment_liked_users('/api/comments/show_like_users.js',comment,comment.topic.site,comment.topic)
          response.body.should include("author_name1")
          response.body.should include("author_name2")
        end
      end
    end
  end  
end
