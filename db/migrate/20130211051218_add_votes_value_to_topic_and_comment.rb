class AddVotesValueToTopicAndComment < ActiveRecord::Migration
  def change
    add_column :comments, :votes_value, :integer
    add_column :topics, :votes_value, :integer
  end
end
