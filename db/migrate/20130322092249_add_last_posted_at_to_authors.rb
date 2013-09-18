class AddLastPostedAtToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :last_posted_at, :datetime, :null => false, :default => Time.zone.now
  end
end
