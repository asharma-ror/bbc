namespace :update_vote_counts do

  desc "Update vote counts and votes_value into topic and comment"
  task :topic => :environment do
    Topic.scoped.each do |topic|
      topic.vote_counts = topic.users_and_guests_likes_string
      topic.votes_value = topic.total_likes_value
      topic.save
      puts "Updated Topic likes:  #{topic.vote_counts}, #{topic.votes_value}"
    end
  end
  
  task :comment => :environment do
    Comment.scoped.each do |comment|
      comment.vote_counts = comment.users_and_guests_likes_string
      comment.votes_value = comment.total_likes_value
      comment.save
      puts "Updated Comment likes:  #{comment.vote_counts}, #{comment.votes_value}"
    end
  end

  task :comment_vote => :environment do
    Comment.scoped.each do |comment|
      votes = comment.votes.where("votes.like > ?",1)
      votes.each do |vote|
        like_count = vote.like
        puts "creating vote for comment id: #{comment.id}"
        for i in 2..like_count
          auther_ip = "127.0.0.#{i}"
          new_vote = comment.votes.create!(:author_ip => auther_ip,
            :author_user_agent => "Mozilla/5.0",
            :referer => vote.referer,
            :like => 1)
          puts "new vote: #{new_vote.id} created"
        end
        vote.update_attribute(:like, 1)
        puts "vote: #{vote.id} updated"
      end
    end
  end
  
  task :topic_vote => :environment do
    Topic.all.each do |topic|
      votes = topic.votes.where("votes.like > ?",1)
      votes.each do |vote|
        like_count = vote.like
        puts "creating vote for topic id: #{topic.id}"
        for i in 2..like_count
          auther_ip = "127.0.0.#{i}"
          new_vote = topic.votes.create!(:author_ip => auther_ip,
            :author_user_agent => "Mozilla/5.0",
            :referer => vote.referer,
            :like => 1)
          puts "new vote: #{new_vote.id} created"
        end
        vote.update_attribute(:like, 1)
        puts "vote: #{vote.id} updated"
      end
    end
  end

  task :comment_vote_update => :environment do
    Vote.skip_callback(:save, :after, :update_vote_counts)
    Vote.skip_callback(:destroy, :after, :update_vote_counts)
    Comment.scoped.each do |comment|
      votes = comment.guest_votes
      if votes.size > 1
        puts "deleting vote for comment id: #{comment.id}"
        votes.each_with_index do |vote,index|
          if index == 0
            vote.update_attribute(:like,votes.size)
            puts "updated vote's like: #{vote.like}"
          else
            vote.destroy
          end
        end
      end
    end
    Vote.set_callback(:save, :after, :update_vote_counts)
    Vote.set_callback(:destroy, :after, :update_vote_counts)
  end

  task :topic_vote_update => :environment do
    Topic.all.each do |topic|
      votes = topic.guest_votes
      if votes.count > 1
        puts "deleting vote for topic id: #{topic.id}"
        votes.each_with_index do |vote,index|
          if index == 0
            vote.update_attribute(:like,votes.count)
            puts "updated vote's like: #{vote.like}"
          else
            vote.destroy
          end
        end
      end
    end
  end


end
