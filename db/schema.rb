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

ActiveRecord::Schema[8.0].define(version: 2025_10_26_084238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "account_ledgers", force: :cascade do |t|
    t.date "date", null: false
    t.integer "entry_no", null: false
    t.string "reference"
    t.string "operation", limit: 20, null: false
    t.integer "account_id", null: false
    t.decimal "amount", precision: 14, scale: 2, default: "0.0", null: false, comment: "借方がプラス"
    t.string "currency", limit: 3, null: false, comment: "取引通貨"
    t.decimal "exchange_rate", precision: 14, scale: 4, default: "1.0", null: false
    t.decimal "account_balance", precision: 14, scale: 2, default: "0.0", null: false
    t.string "description", null: false
    t.integer "creator_id", null: false
    t.integer "approver_id"
    t.datetime "approver_datetime", precision: nil
    t.integer "nuller_id"
    t.datetime "nuller_datetime", precision: nil
    t.boolean "inverse", default: false, null: false
    t.boolean "has_error", default: false
    t.string "error_messages"
    t.string "status", limit: 50, default: "approved", null: false
    t.integer "inventory_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updater_id"
    t.index ["account_id"], name: "index_account_ledgers_on_account_id"
    t.index ["inventory_id"], name: "index_account_ledgers_on_inventory_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "currency", limit: 3
    t.boolean "active", default: true, null: false
    t.string "description", limit: 500, null: false
    t.string "accountable_type", limit: 80
    t.integer "accountable_id"
    t.string "subtype", limit: 40, null: false
    t.decimal "exchange_rate", precision: 14, scale: 4, default: "1.0"
    t.boolean "has_error", default: false, null: false
    t.jsonb "error_messages"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "tag_ids", default: [], array: true
    t.integer "updater_id"
    t.decimal "tax_percentage", precision: 5, scale: 2, default: "0.0"
    t.integer "tax_id"
    t.boolean "tax_in_out", default: false
    t.jsonb "extras"
    t.integer "creator_id", null: false
    t.integer "nuller_id"
    t.index ["creator_id"], name: "index_accounts_on_creator_id"
    t.index ["extras"], name: "index_accounts_on_extras"
    t.index ["name"], name: "index_accounts_on_name", unique: true
    t.index ["nuller_id"], name: "index_accounts_on_nuller_id"
    t.index ["tag_ids"], name: "index_accounts_on_tag_ids"
    t.index ["tax_id"], name: "index_accounts_on_tax_id"
    t.index ["tax_in_out"], name: "index_accounts_on_tax_in_out"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.string "attachment_uid"
    t.string "name"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.integer "user_id"
    t.integer "position", default: 0
    t.boolean "image", default: false
    t.integer "size"
    t.json "image_attributes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "publish", default: false
    t.index ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type"
    t.index ["image"], name: "index_attachments_on_image"
    t.index ["publish"], name: "index_attachments_on_publish"
    t.index ["user_id"], name: "index_attachments_on_user_id"
  end

  create_table "cashes", force: :cascade do |t|
    t.string "bank_name", comment: "銀行名+支店名"
    t.string "bank_addr"
    t.string "account_no"
    t.string "account_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_name", "account_no"], name: "index_cashes_on_bank_name_and_account_no", unique: true
  end

  create_table "contact_accounts", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.string "bank_name", comment: "銀行名+支店名"
    t.string "bank_addr"
    t.string "account_no"
    t.string "account_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "account_no"], name: "index_contact_accounts_on_contact_id_and_account_no", unique: true
    t.index ["contact_id"], name: "index_contact_accounts_on_contact_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.string "matchcode", limit: 100, null: false
    t.string "name", null: false
    t.string "address", limit: 250, comment: "headquarters"
    t.string "phone", limit: 40
    t.string "mobile", limit: 40
    t.string "email", limit: 200
    t.string "tax_number", limit: 30
    t.string "aditional_info", limit: 250
    t.string "position"
    t.boolean "active", default: true, null: false
    t.boolean "staff", default: false, null: false
    t.boolean "client", default: false, null: false
    t.boolean "supplier", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "incomes_status", default: "{}"
    t.jsonb "expenses_status", default: "{}"
    t.integer "tag_ids", default: [], array: true
    t.index ["matchcode"], name: "index_contacts_on_matchcode", unique: true
    t.index ["tag_ids"], name: "index_contacts_on_tag_ids"
    t.index ["tax_number"], name: "index_contacts_on_tax_number", unique: true
  end

  create_table "histories", force: :cascade do |t|
    t.integer "user_id", null: false, comment: "created by"
    t.string "historiable_type", null: false
    t.bigint "historiable_id", null: false
    t.boolean "new_item", default: false, null: false
    t.json "history_data", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "klass_type"
    t.jsonb "extras"
    t.jsonb "all_data", default: {}, null: false
    t.index ["historiable_type", "historiable_id"], name: "index_histories_on_historiable_type_and_historiable_id"
  end

  create_table "inventories", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.string "ref_number"
    t.string "operation", limit: 10, null: false
    t.string "state", limit: 50, null: false
    t.integer "order_id"
    t.integer "store_id", null: false
    t.integer "account_id"
    t.string "description", null: false
    t.decimal "total", precision: 14, scale: 2, default: "0.0", null: false, comment: "機能通貨建ての金額"
    t.integer "creator_id", null: false
    t.integer "store_to_id"
    t.boolean "has_error", default: false, null: false
    t.jsonb "error_messages"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "updater_id"
    t.index ["account_id"], name: "index_inventories_on_account_id"
    t.index ["order_id"], name: "index_inventories_on_order_id"
    t.index ["store_id"], name: "index_inventories_on_store_id"
  end

  create_table "inventory_details", force: :cascade do |t|
    t.integer "inventory_id", null: false
    t.integer "movement_type", limit: 2, null: false
    t.integer "item_id", null: false
    t.decimal "price", precision: 14, scale: 4, default: "0.0", null: false, comment: "機能通貨建ての単価"
    t.integer "store_id", null: false
    t.decimal "quantity", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["inventory_id", "item_id"], name: "index_inventory_details_on_inventory_id_and_item_id", unique: true
    t.index ["inventory_id"], name: "index_inventory_details_on_inventory_id"
    t.index ["item_id"], name: "index_inventory_details_on_item_id"
    t.index ["store_id"], name: "index_inventory_details_on_store_id"
  end

  create_table "item_accountings", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "item_type", limit: 40, null: false
    t.integer "stock_ac_id", null: false
    t.integer "revenue_ac_id", null: false
    t.integer "purchase_ac_id", null: false
    t.integer "ending_inv_ac_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ending_inv_ac_id"], name: "index_item_accountings_on_ending_inv_ac_id"
    t.index ["purchase_ac_id"], name: "index_item_accountings_on_purchase_ac_id"
    t.index ["revenue_ac_id"], name: "index_item_accountings_on_revenue_ac_id"
    t.index ["stock_ac_id"], name: "index_item_accountings_on_stock_ac_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "unit_id", null: false
    t.decimal "price", precision: 14, scale: 2, default: "0.0", null: false
    t.string "name", limit: 255, null: false
    t.string "description", null: false
    t.string "code", limit: 100, null: false
    t.boolean "for_sale", default: true, null: false
    t.boolean "stockable", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "buy_price", precision: 14, scale: 2, default: "0.0", null: false
    t.string "unit_symbol", limit: 20
    t.string "unit_name", limit: 255
    t.integer "tag_ids", default: [], array: true
    t.integer "updater_id"
    t.integer "creator_id", null: false
    t.integer "accounting_id", null: false
    t.index ["accounting_id"], name: "index_items_on_accounting_id"
    t.index ["code"], name: "index_items_on_code", unique: true
    t.index ["creator_id"], name: "index_items_on_creator_id"
    t.index ["unit_id"], name: "index_items_on_unit_id"
    t.index ["updater_id"], name: "index_items_on_updater_id"
  end

  create_table "links", force: :cascade do |t|
    t.integer "organisation_id", null: false
    t.integer "user_id", null: false
    t.string "settings"
    t.boolean "creator", default: false, null: false
    t.boolean "master_account", default: false, null: false
    t.string "role", limit: 50, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "api_token"
    t.index ["api_token"], name: "index_links_on_api_token", unique: true
    t.index ["organisation_id"], name: "index_links_on_organisation_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "loans", force: :cascade do |t|
    t.string "bank_name", null: false, comment: "銀行名+支店名"
    t.decimal "interest_rate", precision: 7, scale: 4, null: false, comment: "percent"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movement_details", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "item_id"
    t.integer "account_id"
    t.decimal "quantity", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "price", precision: 14, scale: 2, default: "0.0", null: false
    t.string "description", null: false
    t.decimal "balance", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_movement_details_on_account_id"
    t.index ["item_id"], name: "index_movement_details_on_item_id"
    t.index ["order_id", "item_id"], name: "index_movement_details_on_order_id_and_item_id", unique: true
    t.index ["order_id"], name: "index_movement_details_on_order_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.string "type", limit: 80, null: false
    t.date "date", null: false
    t.integer "contact_id"
    t.integer "store_id"
    t.integer "trans_to_id"
    t.integer "prod_item_id"
    t.decimal "gross_total", precision: 14, scale: 2, default: "0.0"
    t.decimal "total", precision: 14, scale: 2, default: "0.0", null: false
    t.string "currency", limit: 3
    t.string "bill_number"
    t.decimal "original_total", precision: 14, scale: 2, default: "0.0"
    t.decimal "balance_inventory", precision: 14, scale: 2, default: "0.0"
    t.date "ship_date", comment: "If FOB and *CIF*, the date on the port of departure"
    t.string "delivery_loc"
    t.string "incoterms", limit: 10
    t.date "delivery_date"
    t.integer "creator_id", null: false
    t.integer "approver_id"
    t.datetime "approver_datetime", precision: nil
    t.integer "nuller"
    t.datetime "nuller_datetime", precision: nil
    t.string "null_reason", limit: 400
    t.boolean "delivered", default: false, null: false
    t.boolean "discounted", default: false, null: false
    t.boolean "devolution", default: false, null: false
    t.string "state", limit: 50, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "no_inventory", default: false, null: false
    t.index ["contact_id"], name: "index_orders_on_contact_id"
    t.index ["prod_item_id"], name: "index_orders_on_prod_item_id"
    t.index ["store_id"], name: "index_orders_on_store_id"
    t.index ["trans_to_id"], name: "index_orders_on_trans_to_id"
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "address"
    t.string "address_alt"
    t.string "phone", limit: 40
    t.string "phone_alt", limit: 40
    t.string "mobile", limit: 40
    t.string "email"
    t.string "website"
    t.date "due_date"
    t.text "preferences"
    t.string "time_zone", limit: 100
    t.string "tenant", limit: 50, null: false
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "country_code", limit: 2, null: false
    t.boolean "inventory_active", default: true
    t.text "settings"
    t.date "due_on"
    t.string "plan", default: "2users"
    t.index ["tenant"], name: "index_organisations_on_tenant", unique: true
  end

  create_table "stocks", force: :cascade do |t|
    t.integer "store_id"
    t.integer "item_id"
    t.decimal "unitary_cost", precision: 14, scale: 2, default: "0.0"
    t.decimal "quantity", precision: 14, scale: 2, default: "0.0"
    t.decimal "minimum", precision: 14, scale: 2, default: "0.0"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "active", default: true
    t.index ["active"], name: "index_stocks_on_active"
    t.index ["item_id"], name: "index_stocks_on_item_id"
    t.index ["minimum"], name: "index_stocks_on_minimum"
    t.index ["quantity"], name: "index_stocks_on_quantity"
    t.index ["store_id"], name: "index_stocks_on_store_id"
    t.index ["user_id"], name: "index_stocks_on_user_id"
  end

  create_table "stores", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "phone", limit: 40
    t.boolean "active", default: true, null: false
    t.string "description", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tag_groups", force: :cascade do |t|
    t.string "name"
    t.string "bgcolor"
    t.integer "tag_ids", default: [], array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_tag_groups_on_name", unique: true
    t.index ["tag_ids"], name: "index_tag_groups_on_tag_ids"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "bgcolor", limit: 10
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "taxes", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "abreviation", limit: 20
    t.decimal "percentage", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.string "name", limit: 100
    t.string "symbol", limit: 20
    t.boolean "integer", default: false
    t.boolean "visible", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", limit: 80, null: false
    t.string "last_name", limit: 80, null: false
    t.string "phone", limit: 40
    t.string "mobile", limit: 40
    t.string "website", limit: 200
    t.string "description", limit: 255
    t.string "crypted_password"
    t.string "salt"
    t.string "confirmation_token", limit: 60
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "confirmed_at", precision: nil
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "reseted_password_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "last_sign_in_at", precision: nil
    t.boolean "change_default_password", default: false
    t.string "address"
    t.boolean "active", default: true, null: false
    t.string "auth_token"
    t.string "rol", limit: 50
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "old_emails", default: [], array: true
    t.string "locale", default: "en"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "account_ledgers", "accounts"
  add_foreign_key "account_ledgers", "inventories"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contact_accounts", "contacts"
  add_foreign_key "inventories", "accounts"
  add_foreign_key "inventories", "orders"
  add_foreign_key "inventories", "stores"
  add_foreign_key "inventory_details", "inventories"
  add_foreign_key "inventory_details", "items"
  add_foreign_key "inventory_details", "stores"
  add_foreign_key "item_accountings", "accounts", column: "ending_inv_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "purchase_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "revenue_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "stock_ac_id"
  add_foreign_key "items", "item_accountings", column: "accounting_id"
  add_foreign_key "items", "units"
  add_foreign_key "links", "organisations"
  add_foreign_key "links", "users"
  add_foreign_key "movement_details", "accounts"
  add_foreign_key "movement_details", "items"
  add_foreign_key "movement_details", "orders"
  add_foreign_key "orders", "contacts"
  add_foreign_key "orders", "items", column: "prod_item_id"
  add_foreign_key "orders", "stores"
  add_foreign_key "orders", "stores", column: "trans_to_id"
end
