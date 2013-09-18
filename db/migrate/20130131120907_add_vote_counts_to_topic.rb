class AddVoteCountsToTopic < ActiveRecord::Migration
  def change
    add_column :comments, :vote_counts, :string
    add_column :topics, :vote_counts, :string
  end
end
