class ChangeDatatypeTopic < ActiveRecord::Migration
  def up
    change_column :topics, :title, :text, :null => false
    change_column :topics, :url, :text, :null => false
  end

  def down
    change_column :topics, :title, :string, :null => false
    change_column :topics, :url, :string, :null => false
  end
end
