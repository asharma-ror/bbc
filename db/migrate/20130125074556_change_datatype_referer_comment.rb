class ChangeDatatypeRefererComment < ActiveRecord::Migration
  def up
    change_column :comments, :referer, :text
  end

  def down
    change_column :comments, :referer, :string
  end
end
