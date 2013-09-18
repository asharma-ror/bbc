class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.references :comment
      t.string :author_name
      t.string :author_email
      t.string :author_ip
      t.string :author_user_agent
      t.string :referer
      t.integer :guest_count

      t.datetime :created_at, :null => false
    end
  end
end
