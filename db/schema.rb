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

ActiveRecord::Schema.define(:version => 20120401124859) do

  create_table "batch_logs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_at"
    t.datetime "end_at"
    t.float    "process_time"
    t.string   "status"
    t.text     "result"
    t.integer  "total_count"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "rooms", :force => true do |t|
    t.integer  "user_id"
    t.string   "hash_tag"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "hash_tag_position",              :default => "after"
    t.boolean  "twitter_synchro",                :default => true
    t.string   "search_query"
    t.integer  "last_max_id",       :limit => 8
    t.datetime "last_tweet_at"
    t.boolean  "worker_flag",                    :default => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "room_id"
    t.text     "post"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "from_twitter_id",      :limit => 8
    t.integer  "from_twitter_user_id", :limit => 8
    t.string   "from_twitter_user"
    t.string   "user_image_url"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "screen_name"
    t.string   "image"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "token"
    t.string   "secret"
  end

end
