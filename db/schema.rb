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

ActiveRecord::Schema.define(version: 2019_01_17_180005) do

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collection_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "tag_id"
    t.integer "location"
    t.integer "order"
    t.boolean "hidden", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "featured"
    t.string "slug"
    t.index ["tag_id"], name: "fk_rails_30f4d945f5"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "directory_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.float "boundlat1"
    t.float "boundlng1"
    t.float "boundlat2"
    t.float "boundlng2"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.string "neighbourhood"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "location_type"
    t.index ["location_type"], name: "index_directory_locations_on_location_type"
  end

  create_table "ethicalities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "icon_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ethicalities_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "ethicality_id", null: false
    t.bigint "user_id", null: false
    t.index ["ethicality_id"], name: "index_ethicalities_users_on_ethicality_id"
    t.index ["user_id"], name: "index_ethicalities_users_on_user_id"
  end

  create_table "images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.integer "cover_offset_x", default: 0
    t.integer "cover_offset_y", default: 0
    t.integer "width"
    t.integer "height"
  end

  create_table "jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "job_type"
    t.integer "status"
    t.integer "progress"
    t.text "payload"
    t.text "error_msg"
    t.text "error_stack_trace"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listing_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "listing_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_listing_categories_on_category_id"
    t.index ["listing_id"], name: "index_listing_categories_on_listing_id"
  end

  create_table "listing_ethicalities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "listing_id"
    t.integer "ethicality_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ethicality_id"], name: "fk_rails_d9bdd7ec3d"
    t.index ["listing_id"], name: "fk_rails_efbbfd4677"
  end

  create_table "listing_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "listing_id"
    t.integer "image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "fk_rails_0e6d2aa2ed"
    t.index ["listing_id"], name: "fk_rails_247befc35d"
  end

  create_table "listing_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "listing_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "fk_rails_66e3a27647"
    t.index ["tag_id"], name: "fk_rails_f7ee40ab29"
  end

  create_table "listings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "bio", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.integer "visibility", default: 0
    t.string "website"
    t.string "phone"
    t.string "facebook_uri"
    t.string "claim_id"
    t.integer "claim_status", default: 0
    t.bigint "directory_location_id"
    t.index ["bio"], name: "index_listings_on_bio", type: :fulltext
    t.index ["directory_location_id"], name: "index_listings_on_directory_location_id"
    t.index ["title"], name: "index_listings_on_title", type: :fulltext
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "listing_id"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone", default: "UTC"
    t.string "address"
    t.string "city"
    t.string "region"
    t.string "country"
    t.index ["listing_id"], name: "fk_rails_01cf783517"
  end

  create_table "menu_images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "menu_id"
    t.integer "image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id"], name: "fk_rails_f68dd1a7ff"
    t.index ["menu_id"], name: "fk_rails_bd919e3edc"
  end

  create_table "menus", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "listing_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "fk_rails_0b1d0b7acf"
  end

  create_table "operating_hours", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "day"
    t.time "open"
    t.time "close"
    t.integer "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "open_time"
    t.time "close_time"
    t.index ["listing_id"], name: "fk_rails_dc4815c034"
  end

  create_table "plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "listing_id"
    t.string "plan_type"
    t.decimal "price", precision: 16, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_plans_on_listing_id"
  end

  create_table "seo_paths", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "path"
    t.string "title"
    t.string "description"
    t.string "header"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "hashtag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "use_type", default: 0
    t.index ["hashtag"], name: "index_tags_on_hashtag", type: :fulltext
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "password_digest"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_token"
    t.string "forgot_password_token"
    t.boolean "admin"
    t.string "contact_number"
    t.string "position"
  end

  add_foreign_key "collections", "tags"
  add_foreign_key "listing_ethicalities", "ethicalities"
  add_foreign_key "listing_ethicalities", "listings"
  add_foreign_key "listing_images", "images"
  add_foreign_key "listing_images", "listings"
  add_foreign_key "listing_tags", "listings"
  add_foreign_key "listing_tags", "tags"
  add_foreign_key "listings", "directory_locations"
  add_foreign_key "locations", "listings"
  add_foreign_key "menu_images", "images"
  add_foreign_key "menu_images", "menus"
  add_foreign_key "menus", "listings"
  add_foreign_key "operating_hours", "listings"
end
