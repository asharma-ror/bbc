class AddCommentOpenToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :comments_open, :boolean, :default => true
  end
end
