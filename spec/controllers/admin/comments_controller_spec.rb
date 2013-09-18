require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

describe Admin::CommentsController do

  describe "sign_in as moderator" do

    def create_moderator
      @moderator = User.create!({:email => 'moderator@gmail.com',
       :password => 123456,
       :password_confirmation => 123456,
       :roles => ["site_moderator", ""]
       }, :as => :admin)
    end

    def assign_site(user,site)
      user.site_moderators.create!(:site_id => site.id)
    end

    def create_site
      @site = FactoryGirl.create(:site1,:user =>admin)
    end

    def create_topic(site, options={})
      @topic = FactoryGirl.create(:topic, :key => options[:key], :site_id => site.id)
    end

    def create_comment(topic_id, options={})
      @comment = FactoryGirl.create(:comment,:topic_id => topic_id, :content => options[:content], :author_email => options[:author_email])
    end

    before :each do
      create_site
      create_moderator
      sign_in(@moderator)
    end

    it "should list comments of assigned site" do
      assign_site(@moderator,@site)
      create_topic(@site, {:key => 'topic'})
      create_comment(@topic.id, {:content => "test comment"})
      get :index, :site_id => @site.id
      response.should render_template("admin/comments/index")
    end

    it "should not list comments of un-assigned site" do
      create_topic(@site, {:key => 'topic'})
      create_comment(@topic.id, {:content => "test comment"})
      get :index, :site_id => @site.id
      response.should_not render_template("admin/comments/index")
    end

    it "should edit comment of assigned site" do
      assign_site(@moderator,@site)
      create_topic(@site, {:key => 'topic'})
      create_comment(@topic.id, {:content => "test comment"})
      get :edit, :site_id => @site.id, :id => @comment.id.to_s
      assigns(:comment).should eq(@comment)
      response.should render_template("admin/comments/edit")
    end

    it "should not edit comment of un-assigned site" do
      create_topic(@site, {:key => 'topic'})
      create_comment(@topic.id, {:content => "test comment"})
      get :edit, :site_id => @site.id, :id => @comment.id.to_s
      response.should render_template("shared/forbidden")
    end

    it "should not delete comments of un-assigned site" do
      create_topic(@site, {:key => 'topic'})
      create_comment(@topic.id, {:content => "test comment"})
      get :destroy, :site_id => @site.id, :id => @comment.id.to_s
      response.should render_template("shared/forbidden")
    end

    it "should destroy comments of a user" do
      topic1 = create_topic(@site, {:key => 'topic1'})
      topic2 = create_topic(@site, {:key => 'topic2'})
      topic1_comment1 = create_comment(topic1.id, {:content => "test comment", :author_email => "xyz@gmail.com" })
      topic1_comment2 = create_comment(topic1.id, {:content => "test comment", :author_email => "abc@gmail.com" })
      topic2_comment1 = create_comment(topic2.id, {:content => "test comment", :author_email => "xyz@gmail.com" })
      topic2_comment2 = create_comment(topic2.id, {:content => "test comment", :author_email => "abc@gmail.com" })
      delete :destroy_comments_by_author, {:site_id => @site.id, :author_email => 'xyz@gmail.com'}
      @site.comments.should_not include(topic1_comment1,topic2_comment1)
      @site.comments.should include(topic1_comment2,topic2_comment2)
      response.should redirect_to(admin_site_comments_path)
    end
  end  
end
