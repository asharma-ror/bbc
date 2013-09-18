class ChangeUserAgentFieldDatatypeInVotes < ActiveRecord::Migration
  def up
    change_column :votes, :author_user_agent, :text, :null => true
  end

  def down
    change_column :votes, :author_user_agent, :string, :null => true
  end
end
