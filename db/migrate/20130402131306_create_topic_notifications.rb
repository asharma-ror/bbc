class CreateTopicNotifications < ActiveRecord::Migration
  def change
    create_table :topic_notifications do |t|
      t.integer :topic_id
      t.integer :author_id

      t.timestamps
    end
  end
end
