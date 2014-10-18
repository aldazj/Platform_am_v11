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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140819163753) do

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "assets", force: true do |t|
    t.integer  "videoitem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "assets", ["videoitem_id"], name: "index_assets_on_videoitem_id", using: :btree

  create_table "comments", force: true do |t|
    t.string   "message"
    t.boolean  "is_available"
    t.date     "date"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.integer  "video_clip_id"
  end

  add_index "comments", ["person_id"], name: "index_comments_on_person_id", using: :btree

  create_table "formatvideos", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "format_file_name"
    t.string   "format_content_type"
    t.integer  "format_file_size"
    t.datetime "format_updated_at"
    t.string   "type"
    t.integer  "video_clip_id"
  end

  add_index "formatvideos", ["video_clip_id"], name: "index_formatvideos_on_video_clip_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_people", force: true do |t|
    t.integer "group_id"
    t.integer "person_id"
  end

  add_index "groups_people", ["group_id"], name: "index_groups_people_on_group_id", using: :btree
  add_index "groups_people", ["person_id"], name: "index_groups_people_on_person_id", using: :btree

  create_table "groups_rights", force: true do |t|
    t.integer "group_id"
    t.integer "right_id"
  end

  add_index "groups_rights", ["group_id"], name: "index_groups_rights_on_group_id", using: :btree
  add_index "groups_rights", ["right_id"], name: "index_groups_rights_on_right_id", using: :btree

  create_table "groups_video_clips", force: true do |t|
    t.integer "group_id"
    t.integer "video_clip_id"
  end

  add_index "groups_video_clips", ["group_id"], name: "index_groups_video_clips_on_group_id", using: :btree
  add_index "groups_video_clips", ["video_clip_id"], name: "index_groups_video_clips_on_video_clip_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "lastname"
    t.string   "firstname"
    t.string   "email"
    t.date     "dateofbirth"
    t.string   "private_phone"
    t.string   "professional_phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "password_digest_confirm"
    t.string   "remember_token"
    t.string   "type"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "name"
  end

  create_table "personal_groupsrights", force: true do |t|
    t.integer "personalgroup_id"
    t.integer "right_id"
  end

  add_index "personal_groupsrights", ["personalgroup_id"], name: "index_personal_groupsrights_on_personalgroup_id", using: :btree
  add_index "personal_groupsrights", ["right_id"], name: "index_personal_groupsrights_on_right_id", using: :btree

  create_table "personalgroups", force: true do |t|
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "personalgroups", ["person_id"], name: "index_personalgroups_on_person_id", using: :btree

  create_table "rights", force: true do |t|
    t.string   "name"
    t.boolean  "is_available"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thumbnails", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "video_clip_id"
    t.boolean  "main_thumbnail"
  end

  add_index "thumbnails", ["video_clip_id"], name: "index_thumbnails_on_video_clip_id", using: :btree

  create_table "video_clips", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.boolean  "is_available"
    t.date     "date"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "videoitemclip_file_name"
    t.string   "videoitemclip_content_type"
    t.integer  "videoitemclip_file_size"
    t.datetime "videoitemclip_updated_at"
    t.datetime "deleted_at"
    t.integer  "person_id"
    t.string   "videoclip_from_url"
    t.string   "token"
    t.string   "video_suggest_token"
    t.datetime "video_suggest_token_sent_at"
  end

  add_index "video_clips", ["deleted_at"], name: "index_video_clips_on_deleted_at", using: :btree
  add_index "video_clips", ["person_id"], name: "index_video_clips_on_person_id", using: :btree

  create_table "videoitems", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.boolean  "is_available"
    t.date     "date"
    t.integer  "views"
    t.string   "pathvideo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
  end

  add_index "videoitems", ["person_id"], name: "index_videoitems_on_person_id", using: :btree

end
