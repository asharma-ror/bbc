class ChangeDatatypeRefererVoteFlag < ActiveRecord::Migration
  def up
    change_column :votes, :referer, :text
    change_column :flags, :referer, :text
  end

  def down
    change_column :votes, :referer, :string
    change_column :flags, :referer, :string
  end
end
