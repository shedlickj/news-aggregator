# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100720192219) do

  create_table "articles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rss_entry_id"
    t.boolean  "hidden",           :default => false
    t.boolean  "favorite",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "score",            :default => 0.0
    t.string   "cluster"
    t.boolean  "cluster_follower", :default => false
  end

  create_table "clusters", :force => true do |t|
    t.text     "list_of_articles"
    t.text     "spot_matches"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "score",            :default => 0
  end

  create_table "feeds", :force => true do |t|
    t.string   "uri"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lists_by_id"
    t.string   "rank"
    t.integer  "user_id"
    t.integer  "user_update_rank", :default => 0
  end

  create_table "lists", :force => true do |t|
    t.string   "feeds_by_id"
    t.boolean  "default_list", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "user_id"
    t.boolean  "shared",       :default => false
  end

  create_table "rss_entries", :force => true do |t|
    t.string   "source"
    t.text     "title",          :limit => 255
    t.datetime "published"
    t.string   "link"
    t.text     "description",    :limit => 255
    t.text     "data",           :limit => 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "spot_signature"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
