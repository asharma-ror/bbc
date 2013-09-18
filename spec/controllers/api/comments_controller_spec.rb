require 'spec_helper'

describe Api::CommentsController do
  describe "GET show_topic" do
    def get_boolean_param(value, default = false)
      value = value.downcase
      if value == 'true' || value == 'yes' || value == '1' || value == 'on'
        true
      else
        default
      end
    end
    
    def test_params
      {:topic_title => 'test topic title',:topic_url => 'test/topic/url',:include_base => '1',:include_css => 'yes'}
    end
    
    def visit_normally
      get :show_topic, :topic_title => test_params[:topic_title],:topic_url => test_params[:topic_url],:include_base => test_params[:include_base],:include_css => test_params[:include_css]  
    end
    
    it "assigns the requested topic_title as @topic_title, topic_url as @topic_url, include_base as @include_base and include_css as @include_css" do
      visit_normally
      values = test_params
      assigns(:topic_title).should eq(test_params[:topic_title])
      assigns(:topic_url).should eq(test_params[:topic_url])

      assigns(:include_base).should eq(get_boolean_param(test_params[:include_base], true))
      assigns(:include_css).should eq(get_boolean_param(test_params[:include_css], true))
    end
  end
end
