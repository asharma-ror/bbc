require 'spec_helper'

describe "Flag" do
  before(:each) do
  	@topic = FactoryGirl.create(:topic, :site => hatsuneshima)
    @comment = FactoryGirl.create(:comment, :content => 'first post', :topic => @topic)
    @site_key  = hatsuneshima.key
    @topic_key = @topic.key
    Flag.delete_all
  end

  def flag_attributes
    FactoryGirl.build(:flag).attributes
  end

  it 'Reference is required Flag' do
  	flag = Flag.new flag_attributes
    flag.valid?.should be_false
  end


  it 'Flag Comment has been saved successfully' do
    flag = @comment.flags.create flag_attributes
    flag.should eq(Flag.first)
  end

  it 'Comment: flag message' do
  	flag = @comment.flags.create flag_attributes.merge({:guest_count => 1})
  	@comment.total_flags_str.should eql("1 user flagged. ")
  end

  it 'Comment: User and guest flagged this.' do
  	@comment.flags.create flag_attributes.merge({:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
  	@comment.total_flags_str.should eql("1 user flagged. ")
  	@comment.flags.create flag_attributes.merge({:guest_count => 1})
  	@comment.total_flags_str.should eql("2 users flagged. ")
  	@comment.flags.create flag_attributes.merge({:author_name=>"author_name",
  		:author_email=>"author_name@email.com"})
  	@comment.total_flags_str.should eql("3 users flagged. ")
  end

end
