class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string   :author_email
      t.boolean  :notify_me, :default => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :authors
  end
end
