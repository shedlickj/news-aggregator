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

ActiveRecord::Schema.define(:version => 20100707205649) do

  create_table "clusters", :force => true do |t|
    t.text     "list_of_articles"
    t.text     "spot_matches"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.string   "uri"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lists_by_id"
    t.string   "rank"
  end

  create_table "lists", :force => true do |t|
    t.string   "feeds_by_id"
    t.boolean  "default_list", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "rss_entries", :force => true do |t|
    t.string   "source"
    t.string   "title"
    t.datetime "published"
    t.string   "link"
    t.text     "description",    :limit => 255
    t.string   "data"
    t.boolean  "hidden"
    t.boolean  "favorite"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "spot_signature"
    t.string   "cluster"
  end

end
