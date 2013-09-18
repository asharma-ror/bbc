require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Javascript API", "error handling" do
  describe "comment_flag" do
    def create_new_comment
      admin = FactoryGirl.create(:admin)
      site = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      topic = FactoryGirl.create(:topic,:site_id => site.id)
      comment = FactoryGirl.create(:comment,:topic_id => topic.id)
    end
    
    def post_flag_by_guest(path,site,topic,comment)
      post path, 
        :site_key => site.key, 
        :topic_key => topic.key, 
        :topic_url => topic.url, 
        :topic_title => topic.title,
        :comment_key => comment.id
    end

    def post_flag_by_user(path,author_name,author_email,site,topic,comment)
      post path, 
        :site_key => site.key, 
        :topic_key => topic.key, 
        :topic_url => topic.url, 
        :topic_title => topic.title,
        :comment_key => comment.id,
        :author_name => author_name,
        :author_email => author_email
    end

    def post_flag_with_missing_arg(path,author_name,author_email,site,topic,comment,missing_arg)
      post_flag_hash=Hash.new
      post_flag_hash.merge!(:site_key => site.key)   if missing_arg != :site_key
      post_flag_hash.merge!(:topic_key => topic.key) if missing_arg != :topic_key 
      post_flag_hash.merge!(:topic_url => topic.url) if missing_arg != :topic_url
      post_flag_hash.merge!(:comment_key => comment.id) if missing_arg != :comment_key
      post_flag_hash.merge!(:author_name => author_name) unless author_name.blank?
      post_flag_hash.merge!(:author_email => author_email) unless author_email.blank?
      post path,post_flag_hash
    end
  
    describe "json format" do
      it "flagged by guest" do
        Topic.delete_all
        create_new_comment
        comment = Comment.last
        post_flag_by_guest('/api/post/flag.json',comment.topic.site,comment.topic,comment)
        response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
      end
      
      describe "guest count" do
        def guest_flag_comment(guest_count,comment)
          post_flag_by_guest('/api/post/flag.json',comment.topic.site,comment.topic,comment)
          response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
          flag_comments = comment.flags.where(:author_name => nil).where(:author_email => nil)
          flag_comments.first.guest_count.should eq(guest_count)        
        end

        it "first time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
        end
        
        it "second time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
          guest_flag_comment(2,comment)
        end

        it "third time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
          guest_flag_comment(2,comment)
          guest_flag_comment(3,comment)
        end
      end
      
      it "flagged by user" do
        Topic.delete_all
        create_new_comment
        comment = Comment.last
        post_flag_by_user('/api/post/flag.json','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment)
        response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
        Flag.last.author_name.should eq('test_user')
        Flag.last.author_email.should eq('test_user@mailinator.com')
      end

      describe "user count" do
        def user_flag_comment(user_count,author_name,author_email,comment)
          post_flag_by_user('/api/post/flag.json',author_name,author_email,comment.topic.site,comment.topic,comment)
          response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
          flag_comments = comment.flags.where("author_name IS NOT NULL and author_email  IS NOT NULL")
          flag_comments.count.should eq(user_count)        
        end

        it "first time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
        end
        
        it "second time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
        end

        it "third time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(2,'test_user2','test_user2@mailinator.com',comment)
        end
      end


      describe "missing arguments" do
        describe "guest" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end

        describe "user" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json',nil,nil,comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json',nil,nil,comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json',nil,nil,comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.json',nil,nil,comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end
      end

    end

    describe "js format" do
      it "flagged by guest" do
        Topic.delete_all
        create_new_comment
        comment = Comment.last
        post_flag_by_guest('/api/post/flag.js',comment.topic.site,comment.topic,comment)
        response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
      end
      
      describe "guest count" do
        def guest_flag_comment(guest_count,comment)
          post_flag_by_guest('/api/post/flag.js',comment.topic.site,comment.topic,comment)
          response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
          flag_comments = comment.flags.where(:author_name => nil).where(:author_email => nil)
          flag_comments.first.guest_count.should eq(guest_count)        
        end

        it "first time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
        end
        
        it "second time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
          guest_flag_comment(2,comment)
        end

        it "third time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          guest_flag_comment(1,comment)
          guest_flag_comment(2,comment)
          guest_flag_comment(3,comment)
        end
      end
      
      it "flagged by user" do
        Topic.delete_all
        create_new_comment
        comment = Comment.last
        post_flag_by_user('/api/post/flag.js','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment)
        response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
        Flag.last.author_name.should eq('test_user')
        Flag.last.author_email.should eq('test_user@mailinator.com')
      end

      describe "user count" do
        def user_flag_comment(user_count,author_name,author_email,comment)
          post_flag_by_user('/api/post/flag.js',author_name,author_email,comment.topic.site,comment.topic,comment)
          response.body.should include('{"status":"ok","action":"ReportComment","comment_id":' + comment.id.to_s + ',"flagged":"Flagged"}')
          flag_comments = comment.flags.where("author_name IS NOT NULL and author_email  IS NOT NULL")
          flag_comments.count.should eq(user_count)        
        end

        it "first time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
        end
        
        it "second time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
        end

        it "third time flagged comment" do
          Topic.delete_all
          create_new_comment
          comment = Comment.last
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(1,'test_user1','test_user1@mailinator.com',comment)
          user_flag_comment(2,'test_user2','test_user2@mailinator.com',comment)
        end
      end

      describe "missing arguments" do
        describe "guest" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end

        describe "user" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js',nil,nil,comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js',nil,nil,comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js',nil,nil,comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag.js',nil,nil,comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end        
      end

    end

    describe "other format" do
      describe "missing arguments" do
        describe "guest" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag','test_user','test_user@mailinator.com',comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end

        describe "user" do
          it "if site_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag',nil,nil,comment.topic.site,comment.topic,comment,:site_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag',nil,nil,comment.topic.site,comment.topic,comment,:topic_key)
            comment.flags.count.should eq(0)        
          end

          it "if topic_url is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag',nil,nil,comment.topic.site,comment.topic,comment,:topic_url)
            comment.flags.count.should eq(0)        
          end

          it "if comment_key is missing then flag not created" do
            Topic.delete_all
            create_new_comment
            comment = Comment.last
            post_flag_with_missing_arg('/api/post/flag',nil,nil,comment.topic.site,comment.topic,comment,:comment_key)
            comment.flags.count.should eq(0)        
          end
        end        
      end

    end

  end  
end
