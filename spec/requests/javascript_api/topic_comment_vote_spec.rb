require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe "Javascript API", "error handling" do
  describe "topics_vote" do
    
    def create_new_topic
      admin = FactoryGirl.create(:admin)
      site  = FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      topic = FactoryGirl.create(:topic,:site_id => site.id)
      create_new_comment(topic,"hello world 1", 1)
      create_new_comment(topic,"hello world 2", 2)
      create_new_comment(topic,"hello world 3", 3)
    end
    
    def create_new_comment(topic,content, comment_number)
      FactoryGirl.create(:comment,:topic_id => topic.id,:content=>content, :comment_number => comment_number)
    end

    def show_topic(site_key, topic_key, options = {})
      super(site_key, topic_key, options.merge(
        :pre_js => %Q{
          var Juvia = { supportsCors: false };
        })
      )
    end
    
    it "Guest and User liked this", :js => true do
      Topic.delete_all
      admin = FactoryGirl.create(:admin)
      FactoryGirl.create(:hatsuneshima, :user_id => admin.id)
      post '/api/topic/vote.js', :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com', 
        :topic_title => 'my topic', 
        :vote => 1
      response.body.should include("One guest liked this")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com', 
        :topic_title => 'my topic', :vote => 1
      response.body.should include("2 guests liked this.")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com', 
        :topic_title => 'my topic', :vote => 1
      response.body.should include("3 guests liked this.")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com', 
        :topic_title => 'my topic', :vote => 0
      response.body.should include("2 guests liked this.")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com',
        :author_name => "author_name1",
        :author_email => "author_name1@email.com",
        :topic_title => 'my topic', :vote => 1
      response.body.should include("One user and 2 guests liked this.")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com',
        :author_name => "author_name2",
        :author_email => "author_name2@email.com",
        :topic_title => 'my topic', :vote => 1
      response.body.should include("2 users and 2 guests liked this.")
      post '/api/topic/vote.js', 
        :site_key => 'hatsuneshima', 
        :topic_key => 'topic', 
        :topic_url => 'http://www.google.com',
        :author_name => "author_name3",
        :author_email => "author_name3@email.com",
        :topic_title => 'my topic', :vote => 1
      response.body.should include("3 users and 2 guests liked this.")
      topic = Topic.last
      show_topic(topic.site.key, topic.key)
      find("#liked_pages").click
      within("#users_liker") do
        page.should have_css('#users_like_header', :text => 'People who liked this')
        find(".modal-body").text.should include("author_name1")
        find(".modal-body").text.should include("author_name2")
        find(".modal-body").text.should include("author_name3")
     end
    end
    
    pending "user vote for topic", :js => true do
      create_new_topic
      topic = Topic.last
      show_topic(topic.site.key, topic.key)
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user liked this.')
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user and One guest liked this.')
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user and 2 guests liked this.')
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user and 3 guests liked this.')
      
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
      end
      
      show_topic(topic.site.key, topic.key)
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
      end
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
      end
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user and One guest liked this.")
        end
      end
      
      show_topic(topic.site.key, topic.key)
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          comment_id = like_link["data-comment-id"]
          find("#comment-vote-#{comment_id}").click
        end
      end
      
      within("#users_liker") do
        page.should have_css('#users_like_header', :text => 'People who liked this')
        find(".modal-body").text.should include("test")
     end
      # Need to pass below specs
      #find("#vote_for_unlike").click
      #page.should have_css('#liked_pages',:visible => true, :text => 'One user and 2 guests liked this.')
    end
    
    it "user vote like/unlike for topic", :js => true do
      create_new_topic
      topic = Topic.last
      show_topic(topic.site.key, topic.key)
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user liked this.')
      find("#vote_for_like").click
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One user liked this.')
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One user liked this.")
        end
      end
      
    end
    
    pending "guest vote for topic and comment", :js => true, :focus => true do
      create_new_topic
      topic = Topic.last
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One guest liked this.')
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => '2 guests liked this.')
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => 'One guest liked this.')
      find("#vote_for_like").click
      page.should have_css('#liked_pages',:visible => true, :text => '2 guests liked this.')
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
      end
      
      show_topic(topic.site.key, topic.key, :guest_view => "1")
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
      end
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"One guest liked this.")
        end
      end
      
      within("#juvia-comments-box") do
        comment_order = all('.juvia-comment')
        within("#" + comment_order[0]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
        within("#" + comment_order[1]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
        within("#" + comment_order[2]['id']) do
          like_link = find(".juvia-vote-to-comment")
          like_link.click()
          comment_id = like_link["data-comment-id"]
          page.should have_css("#comment-vote-#{comment_id}",:visible => true, :text=>"2 guests liked this.")
        end
      end
      
    end
    
  end  
end
