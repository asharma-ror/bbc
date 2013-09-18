require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

$remote_ip = 1

describe "Javascript API", "error handling" do
  describe "topics_vote" do
  
    def create_new_topics
      admin = FactoryGirl.create(:admin)
      site = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      topic = FactoryGirl.create(:topic,:site_id => site.id)
    end
    
    def get_topic_liked_users(path,site,topic)
      topic_user_hash=Hash.new
      topic_user_hash.merge!(:site_key => site.key)
      topic_user_hash.merge!(:topic_key => topic.key)
      post path,topic_user_hash
    end

    def post_topics_vote(path,author_name,author_email,vote,site,topic)
      post_vote_hash=Hash.new
      post_vote_hash.merge!(:site_key => site.key)
      post_vote_hash.merge!(:topic_key => topic.key)
      post_vote_hash.merge!(:topic_url => topic.url)
      post_vote_hash.merge!(:vote => vote)
      post_vote_hash.merge!(:author_name => author_name) unless author_name.blank?
      post_vote_hash.merge!(:author_email => author_email) unless author_email.blank?
      post path,post_vote_hash
    end
    
    def post_topics_vote_with_missing_arg(path,author_name,author_email,vote,site,topic,missing_arg)
      post_vote_hash=Hash.new
      post_vote_hash.merge!(:site_key => site.key) if missing_arg != :site_key
      post_vote_hash.merge!(:topic_key => topic.key) if missing_arg != :topic_key
      post_vote_hash.merge!(:topic_url => topic.url) if missing_arg != :topic_url
      post_vote_hash.merge!(:vote => vote) if missing_arg != :vote
      post_vote_hash.merge!(:author_name => author_name) unless author_name.blank?
      post_vote_hash.merge!(:author_email => author_email) unless author_email.blank?
      post path,post_vote_hash
    end

    describe "js format" do
      describe "guest like" do
        it "first time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("One guest liked this")
        end
        it "second time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("2 guests liked this")
        end
        it "third time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 guests liked this")
        end
      end
      describe "guest unlike" do
        it "first time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("One guest liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("2 guests liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 guests liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          response.body.should include("2 guests liked this")
        end
        it "second time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("One guest liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("2 guests liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 guests liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          response.body.should include("2 guests liked this")
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          response.body.should include("One guest liked this")
        end
        it "third time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          response.body.should_not include("liked this")
        end
      end
      describe "user like" do
        it "first time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          response.body.should include("One user liked this")
        end
        it "second time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          response.body.should include("2 users liked this")
        end
        it "third time like" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          response.body.should include("3 users liked this")
        end
        it "same user like mutipal times" do
          create_new_topics
          topic=Topic.last
          5.times do |n|
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          end
          response.body.should include("One user liked this")
        end

      end
      describe "user unlike" do
        it "first time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          response.body.should include("2 users liked this")
        end
        it "second time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',0,topic.site,topic)
          response.body.should include("One user liked this")
        end
        it "third time unlike" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',0,topic.site,topic)
          response.body.should_not include("liked this")
        end

        it "same user unlike mutipal times" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          5.times do |n|
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          end
          response.body.should include("2 users liked this")
        end

      end
      describe "both guest and user like" do
        it "After 3 user liked, first time like guest" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 users and One guest liked this.")
        end
        it "After 3 user liked, second time like guest" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 users and 2 guests liked this.")
        end
        it "After 3 user liked, third time like guest" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          response.body.should include("3 users and 3 guests liked this.")        
        end
        it "After 3 guest liked, first time like user" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)        
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          response.body.should include("One user and 3 guests liked this.")
        end
        it "After 3 guest liked, second time like user" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)        
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          response.body.should include("2 users and 3 guests liked this.")
        end
        it "After 3 guest liked, third time like user" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)        
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          response.body.should include("3 users and 3 guests liked this.")
        end
      end
      describe "both guest and user unlike" do
        before(:each) do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
        end
        
        it "After 3 users and 3 guests liked, first time unlike guest" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          
          response.body.should include("3 users and 2 guests liked this.")
        end
        it "After 3 users and 3 guests liked, second time unlike guest" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          
          response.body.should include("3 users and One guest liked this.")
        end
        it "After 3 users and 3 guests liked, third time unlike guest" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)

          response.body.should include("3 users liked this.")
        end
        it "After 3 users and 3 guests liked, first time unlike user" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)

          response.body.should include("2 users and 3 guests liked this.")
        end
        it "After 3 users and 3 guests liked, second time unlike user" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',0,topic.site,topic)

          response.body.should include("One user and 3 guests liked this.")
        end
        it "After 3 users and 3 guests liked, third time unlike user" do
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',0,topic.site,topic)
          post_topics_vote('/api/topic/vote.js','author_name3','author_name3@email.com',0,topic.site,topic)

          response.body.should include("3 guests liked this.")
        end
      end
      
      describe "missing arguments" do
        describe "guest like" do
          it "if site_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,1,topic.site,topic,:site_key)
            topic.votes.count.should eq(0)
          end
          it "if topic_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,1,topic.site,topic,:topic_key)
            topic.votes.count.should eq(0)
          end
          it "if topic_url is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,1,topic.site,topic,:topic_url)
            topic.votes.count.should eq(0)
          end
          it "if vote is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,1,topic.site,topic,:vote)
            topic.votes.count.should eq(0)
          end
        end

        describe "guest unlike" do
          it "if site_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
            post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,0,topic.site,topic,:site_key)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
          end
          it "if topic_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
            post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,0,topic.site,topic,:topic_key)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
          end
          it "if topic_url is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
            post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,0,topic.site,topic,:topic_url)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
          end
          it "if vote is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js',nil,nil,1,topic.site,topic)
            post_topics_vote('/api/topic/vote.js',nil,nil,0,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js',nil,nil,0,topic.site,topic,:vote)
            topic.votes.sum(:like).should eq(1)
            topic.votes.sum(:unlike).should eq(1)
          end
        end

        describe "user like" do
          it "if site_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic,:site_key)
            topic.votes.sum(:like).should eq(0)
          end
          it "if topic_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic,:topic_key)
            topic.votes.sum(:like).should eq(0)
          end
          it "if topic_url is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic,:topic_url)
            topic.votes.sum(:like).should eq(0)
          end
          it "if vote is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic,:vote)
            topic.votes.sum(:like).should eq(0)
          end
        end

        describe "user unlike" do
          it "if site_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic,:site_key)
            topic.votes.sum(:like).should eq(1)
          end
          it "if topic_key is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic,:topic_key)
            topic.votes.sum(:like).should eq(1)
          end
          it "if topic_url is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic,:topic_url)
            topic.votes.sum(:like).should eq(1)
          end
          it "if vote is missing then vote not created" do
            create_new_topics
            topic=Topic.last
            post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
            topic.votes.sum(:like).should eq(1)
            post_topics_vote_with_missing_arg('/api/topic/vote.js','author_name1','author_name1@email.com',0,topic.site,topic,:vote)
            topic.votes.sum(:like).should eq(1)
          end
        end

      end  
    end
    describe "js format" do
      describe "user like" do
        it "should display users who liked topic" do
          create_new_topics
          topic=Topic.last
          post_topics_vote('/api/topic/vote.js','author_name1','author_name1@email.com',1,topic.site,topic)
          response.body.should include("One user liked this")
          post_topics_vote('/api/topic/vote.js','author_name2','author_name2@email.com',1,topic.site,topic)
          response.body.should include("2 users liked this")
          get_topic_liked_users('/api/comments/show_topic_like_users.js',topic.site,topic)
          response.body.should include("author_name1")
          response.body.should include("author_name2")
        end
      end
    end
  end
end
