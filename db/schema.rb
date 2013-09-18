# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130402141712) do

  create_table "authors", :force => true do |t|
    t.string   "author_email"
    t.boolean  "notify_me",      :default => false
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.datetime "last_posted_at", :default => '2013-04-02 09:21:16', :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean  "admin",                                 :default => false, :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.integer  "roles_mask"
    t.index ["email"], :name => "index_users_on_email", :unique => true, :order => {"email" => :asc}
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true, :order => {"reset_password_token" => :asc}
  end

  create_table "sites", :force => true do |t|
    t.integer  "user_id",                          :null => false
    t.string   "key",                              :null => false
    t.string   "name",                             :null => false
    t.string   "url"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "moderation_method", :default => 0, :null => false
    t.string   "akismet_key"
    t.string   "locale"
    t.index ["key"], :name => "index_sites_on_key", :unique => true, :order => {"key" => :asc}
    t.index ["user_id"], :name => "index_sites_on_user_id", :order => {"user_id" => :asc}
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "sites_user_id_fkey"
  end

  create_table "topics", :force => true do |t|
    t.integer  "site_id",                          :null => false
    t.string   "key",                              :null => false
    t.text     "title",                            :null => false
    t.text     "url",                              :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "last_posted_at"
    t.string   "vote_counts",    :default => "",   :null => false
    t.integer  "votes_value"
    t.boolean  "comments_open",  :default => true
    t.index ["site_id"], :name => "index_topics_on_site_id", :order => {"site_id" => :asc}
    t.index ["site_id", "key"], :name => "index_topics_on_site_id_and_key", :unique => true, :order => {"site_id" => :asc, "key" => :asc}
    t.foreign_key ["site_id"], "sites", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "topics_site_id_fkey"
  end

  create_table "comments", :force => true do |t|
    t.integer  "topic_id",                          :null => false
    t.integer  "moderation_status", :default => 0,  :null => false
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_ip",                         :null => false
    t.text     "author_user_agent"
    t.text     "referer"
    t.text     "content",                           :null => false
    t.datetime "created_at",                        :null => false
    t.integer  "comment_number"
    t.string   "vote_counts",       :default => "", :null => false
    t.string   "flag_status"
    t.integer  "votes_value"
    t.integer  "parent_id"
    t.index ["parent_id"], :name => "fk__comments_parent_id", :order => {"parent_id" => :asc}
    t.index ["topic_id"], :name => "index_comments_on_topic_id", :order => {"topic_id" => :asc}
    t.foreign_key ["parent_id"], "comments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "comments_parent_id_fkey"
    t.foreign_key ["topic_id"], "topics", ["id"], :on_update => :cascade, :on_delete => :cascade, :name => "comments_topic_id_fkey"
  end

  create_table "flags", :force => true do |t|
    t.integer  "comment_id"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_ip"
    t.string   "author_user_agent"
    t.text     "referer"
    t.integer  "guest_count"
    t.datetime "created_at",        :null => false
    t.index ["comment_id"], :name => "index_flags_on_comment_id", :order => {"comment_id" => :asc}
    t.foreign_key ["comment_id"], "comments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "flags_comment_id_fkey"
  end

  create_table "site_moderators", :force => true do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.index ["site_id"], :name => "fk__site_moderators_site_id", :order => {"site_id" => :asc}
    t.index ["user_id"], :name => "fk__site_moderators_user_id", :order => {"user_id" => :asc}
    t.foreign_key ["site_id"], "sites", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "site_moderators_site_id_fkey"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "site_moderators_user_id_fkey"
  end

  create_table "votes", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type",      :default => "Topic"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_ip"
    t.string   "author_user_agent"
    t.text     "referer"
    t.integer  "like"
    t.integer  "unlike"
    t.datetime "created_at",                             :null => false
  end

end
