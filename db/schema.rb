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

ActiveRecord::Schema.define(:version => 20121214145454) do

  create_table "filters", :force => true do |t|
    t.string   "target_url"
    t.string   "user_agent"
    t.string   "class_name"
    t.string   "environment"
    t.string   "hostname"
    t.string   "tag"
    t.text     "message"
    t.text     "params_including"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "flail_exceptions_count", :default => 0, :null => false
  end

  create_table "flail_exceptions", :force => true do |t|
    t.string   "target_url"
    t.string   "referer_url"
    t.string   "user_agent"
    t.string   "class_name"
    t.string   "environment"
    t.string   "hostname"
    t.string   "tag"
    t.text     "user"
    t.text     "rack"
    t.text     "params"
    t.text     "message"
    t.text     "backtrace"
    t.datetime "resolved_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "digest"
    t.integer  "filtered_by"
  end

  add_index "flail_exceptions", ["created_at"], :name => "index_flail_exceptions_on_created_at"
  add_index "flail_exceptions", ["environment"], :name => "index_flail_exceptions_on_environment"
  add_index "flail_exceptions", ["resolved_at"], :name => "index_flail_exceptions_on_resolved_at"
  add_index "flail_exceptions", ["tag"], :name => "index_flail_exceptions_on_tag"

  create_table "web_hooks", :force => true do |t|
    t.boolean  "secure"
    t.string   "event"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
