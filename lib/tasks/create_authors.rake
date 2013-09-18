require 'rest_client'
namespace :create_authors do
  desc "Get all users from rdfnet application and save it into author table at juvia"
  task :create_author => :environment do
    puts "Start time : #{Time.now}"
    users = RestClient.get "http://localhost:3000/fetch_users" rescue nil
    JSON.parse(users).each_with_index do |user|
      author = Author.lookup_or_create_author(user[0],user[1])
    end
    puts "End time : #{Time.now}"
  end
end
