# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_16_192246) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cash_movements", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "cash_session_id", null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.string "description", null: false
    t.integer "kind", default: 0, null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_cash_movements_on_cash_session_id"
    t.index ["created_by_id"], name: "index_cash_movements_on_created_by_id"
    t.index ["restaurant_id"], name: "index_cash_movements_on_restaurant_id"
  end

  create_table "cash_sessions", force: :cascade do |t|
    t.datetime "closed_at"
    t.bigint "closed_by_id"
    t.decimal "counted_amount", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.decimal "difference_amount", precision: 12, scale: 2
    t.decimal "expected_amount", precision: 12, scale: 2
    t.text "notes"
    t.datetime "opened_at", null: false
    t.bigint "opened_by_id", null: false
    t.decimal "opening_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_cash_sessions_on_closed_by_id"
    t.index ["opened_by_id"], name: "index_cash_sessions_on_opened_by_id"
    t.index ["restaurant_id", "status"], name: "index_cash_sessions_on_restaurant_id_and_status"
    t.index ["restaurant_id"], name: "index_cash_sessions_on_restaurant_id"
  end

  create_table "dining_tables", force: :cascade do |t|
    t.integer "capacity", default: 4, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id", "code"], name: "index_dining_tables_on_restaurant_id_and_code", unique: true
    t.index ["restaurant_id"], name: "index_dining_tables_on_restaurant_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.integer "kind", default: 0, null: false
    t.string "name", null: false
    t.boolean "requires_authorization", default: false, null: false
    t.bigint "restaurant_id", null: false
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 12, scale: 2, null: false
    t.index ["restaurant_id"], name: "index_discounts_on_restaurant_id"
  end

  create_table "menu_categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menu_categories_on_restaurant_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "menu_category_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.decimal "price", precision: 12, scale: 2, null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_category_id"], name: "index_menu_items_on_menu_category_id"
    t.index ["restaurant_id"], name: "index_menu_items_on_restaurant_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "menu_item_id", null: false
    t.string "notes"
    t.bigint "order_id", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["restaurant_id"], name: "index_order_items_on_restaurant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "cash_session_id"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.bigint "dining_table_id"
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.bigint "discount_id"
    t.text "notes"
    t.string "order_number", null: false
    t.integer "order_type", default: 0, null: false
    t.bigint "restaurant_id", null: false
    t.integer "status", default: 0, null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_orders_on_cash_session_id"
    t.index ["created_by_id"], name: "index_orders_on_created_by_id"
    t.index ["dining_table_id"], name: "index_orders_on_dining_table_id"
    t.index ["discount_id"], name: "index_orders_on_discount_id"
    t.index ["restaurant_id", "order_number"], name: "index_orders_on_restaurant_id_and_order_number", unique: true
    t.index ["restaurant_id"], name: "index_orders_on_restaurant_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "cash_session_id"
    t.datetime "created_at", null: false
    t.integer "method", default: 0, null: false
    t.bigint "order_id", null: false
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_session_id"], name: "index_payments_on_cash_session_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["restaurant_id"], name: "index_payments_on_restaurant_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "subdomain", null: false
    t.string "timezone", default: "America/Bogota", null: false
    t.datetime "updated_at", null: false
    t.boolean "waiters_can_collect_payment", default: false, null: false
    t.index ["slug"], name: "index_restaurants_on_slug", unique: true
    t.index ["subdomain"], name: "index_restaurants_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.bigint "restaurant_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["restaurant_id"], name: "index_users_on_restaurant_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cash_movements", "cash_sessions"
  add_foreign_key "cash_movements", "restaurants"
  add_foreign_key "cash_movements", "users", column: "created_by_id"
  add_foreign_key "cash_sessions", "restaurants"
  add_foreign_key "cash_sessions", "users", column: "closed_by_id"
  add_foreign_key "cash_sessions", "users", column: "opened_by_id"
  add_foreign_key "dining_tables", "restaurants"
  add_foreign_key "discounts", "restaurants"
  add_foreign_key "menu_categories", "restaurants"
  add_foreign_key "menu_items", "menu_categories"
  add_foreign_key "menu_items", "restaurants"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "restaurants"
  add_foreign_key "orders", "cash_sessions"
  add_foreign_key "orders", "dining_tables"
  add_foreign_key "orders", "discounts"
  add_foreign_key "orders", "restaurants"
  add_foreign_key "orders", "users", column: "created_by_id"
  add_foreign_key "payments", "cash_sessions"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "restaurants"
  add_foreign_key "users", "restaurants"
end
