class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.references :votable, :polymorphic => {:default => 'Topic'}
      t.string   :author_name
      t.string   :author_email
      t.string   :author_ip
      t.string   :author_user_agent
      t.string   :referer
      t.integer  :like
      t.integer  :unlike
      t.datetime :created_at, :null => false
    end
  end

  def self.down
    drop_table :votes
  end
end
