FactoryGirl.define do
  factory :admin, :class => User do
    email 'admin@admin.com'
    password 123456
    password_confirmation 123456
    roles_mask 1
  end

  factory :kotori, :class => User do
    email 'kotori@kotori.jp'
    password 123456
    password_confirmation 123456
  end
  
  factory :morishima, :class => User do
    email 'morishima@morishima.jp'
    password 123456
    password_confirmation 123456
  end
  
  factory :hatsuneshima, :class => Site do
    name 'Hatsuneshima'
    key 'hatsuneshima'
  end
  
  factory :site1, :class => Site do
    name 'Site 1'
    key 'site1'
  end
  
  factory :site2, :class => Site do
    name 'Site 2'
    key 'site2'
  end
  
  factory :site3, :class => Site do
    name 'Site 3'
    key 'site3'
  end
  
  factory :site4, :class => Site do
    name 'Site 4'
    key 'site4'
  end
  
  factory :topic do
    key 'topic'
    title 'my topic'
    url 'http://www.google.com'
  end
  
  factory :comment do
    content 'a comment'
    author_ip '127.0.0.1'
    author_user_agent 'Firefox'
    referer 'http://www.google.com/'
    created_at Time.now
  end
  
  factory :vote do
    author_ip '127.0.0.1'
    author_user_agent 'Firefox'
    referer 'http://www.google.com/'
  end

  factory :flag do
    author_ip '127.0.0.1'
    author_user_agent 'Firefox'
    referer 'http://www.google.com/'
  end

  factory :author do
    author_email 'example@example.com'
    notify_me true
    created_at Time.now
  end
  
  factory :topic_notification do
    author_id '1'
    topic_id '2'
  end
end

module FactoryHelpers
  def admin(attrs = {})
    @admin ||= FactoryGirl.create(:admin, attrs)
  end
  
  def kotori(attrs = {})
    @kotori ||= FactoryGirl.create(:kotori, attrs)
  end
  
  def morishima(attrs = {})
    @morishima ||= FactoryGirl.create(:morishima, attrs)
  end
  
  def hatsuneshima(attrs = {})
    @hatsuneshima ||= FactoryGirl.create(:hatsuneshima,
      { :user => kotori }.merge(attrs))
  end

  def site2(attrs = {})
    @site2 ||= FactoryGirl.create(:site2,
      { :user => kotori }.merge(attrs))
  end
end

