namespace :topic_comments do

  desc "Update redis comment counts of topic"
  task :save_redis => :environment do
    Topic.all.each do |topic| 
      puts "Topic #{topic.url}"
      $redis.set("#{topic.site.key}_#{topic.key.to_s}", topic.comments.size)
      puts "Topic End"
    end
  end

end
