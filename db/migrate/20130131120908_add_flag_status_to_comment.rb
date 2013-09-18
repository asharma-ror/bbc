class AddFlagStatusToComment < ActiveRecord::Migration
  def change
    add_column :comments, :flag_status, :string
  end
end
