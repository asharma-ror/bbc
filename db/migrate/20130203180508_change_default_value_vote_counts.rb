class ChangeDefaultValueVoteCounts < ActiveRecord::Migration
  def up
    change_column :comments, :vote_counts, :string, :null => false, :default => ""
    change_column :topics, :vote_counts, :string, :null => false, :default => ""
  end

  def down
  end
end
