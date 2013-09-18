class AddCommentNumberField < ActiveRecord::Migration
  def change
  	add_column :comments, :comment_number, :integer
  end
end

