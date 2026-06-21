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

ActiveRecord::Schema[8.1].define(version: 2026_06_02_051009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "account_ledgers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.timestamp "approver_datetime"
    t.integer "approver_id"
    t.integer "bp_bank_account_id"
    t.timestamp "created_at", null: false
    t.integer "creator_id", null: false
    t.date "date", null: false
    t.string "description", null: false
    t.integer "entry_no", null: false
    t.jsonb "error_messages"
    t.bigint "funct_amount", null: false
    t.bigint "fx_amount", comment: "借方がプラス"
    t.string "fx_curr_code", limit: 3, comment: "取引通貨"
    t.boolean "has_error", default: false, null: false
    t.integer "inventory_id"
    t.boolean "inverse", default: false, null: false
    t.timestamp "nuller_datetime"
    t.integer "nuller_id"
    t.string "operation", limit: 20, null: false
    t.integer "partner_id"
    t.string "reference"
    t.string "status", limit: 20, default: "approved", null: false
    t.timestamp "updated_at", null: false
    t.integer "updater_id"
    t.index ["account_id"], name: "index_account_ledgers_on_account_id"
    t.index ["bp_bank_account_id"], name: "index_account_ledgers_on_bp_bank_account_id"
    t.index ["inventory_id"], name: "index_account_ledgers_on_inventory_id"
    t.index ["partner_id"], name: "index_account_ledgers_on_partner_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.integer "accountable_id"
    t.string "accountable_type", limit: 80
    t.boolean "active", default: true, null: false
    t.timestamp "created_at", null: false
    t.integer "creator_id", null: false
    t.string "currency", limit: 3
    t.string "description", limit: 500, null: false
    t.jsonb "error_messages"
    t.jsonb "extras"
    t.boolean "has_error", default: false, null: false
    t.string "name", null: false
    t.integer "nuller_id"
    t.string "subtype", limit: 40, null: false
    t.integer "tag_ids", default: [], array: true
    t.boolean "tax_in_out", default: false
    t.timestamp "updated_at", null: false
    t.integer "updater_id"
    t.index ["accountable_type", "accountable_id"], name: "index_accounts_on_accountable_type_and_accountable_id", unique: true
    t.index ["creator_id"], name: "index_accounts_on_creator_id"
    t.index ["extras"], name: "index_accounts_on_extras"
    t.index ["name"], name: "index_accounts_on_name", unique: true
    t.index ["nuller_id"], name: "index_accounts_on_nuller_id"
    t.index ["tag_ids"], name: "index_accounts_on_tag_ids"
    t.index ["tax_in_out"], name: "index_accounts_on_tax_in_out"
  end

  create_table "attachments", force: :cascade do |t|
    t.timestamp "created_at", null: false
    t.jsonb "image_data"
    t.bigint "inventory_id"
    t.bigint "item_id"
    t.string "name", null: false
    t.bigint "order_id"
    t.integer "position", null: false
    t.boolean "publish", default: false
    t.timestamp "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["inventory_id"], name: "index_attachments_on_inventory_id"
    t.index ["item_id"], name: "index_attachments_on_item_id"
    t.index ["order_id"], name: "index_attachments_on_order_id"
    t.index ["publish"], name: "index_attachments_on_publish"
  end

  create_table "bom_structures", force: :cascade do |t|
    t.bigint "child_item_id"
    t.bigint "child_res_id"
    t.integer "child_type", limit: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "parent_id", null: false
    t.decimal "qty", precision: 14, scale: 2, null: false
    t.bigint "sales_order_id"
    t.string "text"
    t.datetime "updated_at", null: false
    t.index ["child_item_id"], name: "index_bom_structures_on_child_item_id"
    t.index ["child_res_id"], name: "index_bom_structures_on_child_res_id"
    t.index ["parent_id"], name: "index_bom_structures_on_parent_id"
    t.index ["sales_order_id"], name: "index_bom_structures_on_sales_order_id"
  end

  create_table "cashes", force: :cascade do |t|
    t.string "account_name"
    t.string "account_no"
    t.string "bank_addr"
    t.string "bank_name", comment: "銀行名+支店名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_no"], name: "index_cashes_on_account_no", unique: true
  end

  create_table "contact_accounts", force: :cascade do |t|
    t.string "account_name", null: false
    t.string "account_no", null: false
    t.string "bank_addr"
    t.string "bank_name", null: false, comment: "銀行名+支店名"
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_no"], name: "index_contact_accounts_on_account_no", unique: true
    t.index ["contact_id"], name: "index_contact_accounts_on_contact_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address", limit: 250, comment: "headquarters"
    t.string "aditional_info", limit: 250
    t.boolean "client", default: false, null: false
    t.string "country_code", limit: 2, null: false
    t.timestamp "created_at", null: false
    t.string "email", limit: 200
    t.jsonb "expenses_status", default: "{}"
    t.jsonb "incomes_status", default: "{}"
    t.string "matchcode", limit: 100, null: false
    t.string "mobile", limit: 40
    t.string "name", null: false
    t.string "phone", limit: 40
    t.string "position"
    t.boolean "staff", default: false, null: false
    t.boolean "supplier", default: false, null: false
    t.integer "tag_ids", default: [], array: true
    t.string "tax_number", limit: 30
    t.timestamp "updated_at", null: false
    t.index ["country_code", "tax_number"], name: "index_contacts_on_country_code_and_tax_number", unique: true
    t.index ["matchcode"], name: "index_contacts_on_matchcode", unique: true
    t.index ["tag_ids"], name: "index_contacts_on_tag_ids"
  end

  create_table "curr_xchgs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "curr_code", limit: 3, null: false
    t.date "date", null: false
    t.float "rate", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "curr_code"], name: "index_curr_xchgs_on_date_and_curr_code", unique: true
  end

  create_table "histories", force: :cascade do |t|
    t.jsonb "all_data", default: {}, null: false
    t.timestamp "created_at", null: false
    t.jsonb "extras"
    t.bigint "historiable_id", null: false
    t.string "historiable_type", null: false
    t.json "history_data", default: {}, null: false
    t.string "klass_type"
    t.boolean "new_item", default: false, null: false
    t.integer "user_id", null: false, comment: "created by"
    t.index ["historiable_type", "historiable_id"], name: "index_histories_on_historiable_type_and_historiable_id"
  end

  create_table "inventories", id: :serial, force: :cascade do |t|
    t.timestamp "created_at", null: false
    t.integer "creator_id", null: false
    t.string "curr_code", limit: 3
    t.date "date", null: false
    t.string "description", null: false
    t.jsonb "error_messages"
    t.boolean "has_error", default: false, null: false
    t.integer "invoice_id"
    t.string "operation", limit: 10, null: false
    t.integer "order_id"
    t.string "ref_number"
    t.string "state", limit: 20, null: false
    t.integer "store_id", null: false
    t.timestamp "updated_at", null: false
    t.integer "updater_id"
    t.index ["invoice_id"], name: "index_inventories_on_invoice_id"
    t.index ["order_id"], name: "index_inventories_on_order_id"
    t.index ["store_id"], name: "index_inventories_on_store_id"
  end

  create_table "inventory_details", force: :cascade do |t|
    t.timestamp "created_at", null: false
    t.integer "inventory_id", null: false
    t.integer "item_id", null: false
    t.decimal "quantity", precision: 14, scale: 2, null: false
    t.bigint "txn_amount", comment: "取引通貨建ての line amount (if any)"
    t.timestamp "updated_at", null: false
    t.index ["inventory_id", "item_id"], name: "index_inventory_details_on_inventory_id_and_item_id", unique: true
    t.index ["inventory_id"], name: "index_inventory_details_on_inventory_id"
    t.index ["item_id"], name: "index_inventory_details_on_item_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "amount_total", null: false
    t.bigint "bp_bank_account_id"
    t.datetime "created_at", null: false
    t.string "curr_code", limit: 3, null: false
    t.date "date", null: false
    t.string "doc_no"
    t.date "due_date", null: false
    t.string "inv_type", limit: 10, null: false
    t.integer "lock_version", null: false
    t.bigint "partner_id", null: false
    t.string "status", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["bp_bank_account_id"], name: "index_invoices_on_bp_bank_account_id"
    t.index ["partner_id", "doc_no"], name: "index_invoices_on_partner_id_and_doc_no", unique: true
    t.index ["partner_id"], name: "index_invoices_on_partner_id"
  end

  create_table "item_accountings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ending_inv_ac_id", null: false
    t.string "item_type", limit: 40, null: false
    t.string "name", null: false
    t.integer "purchase_ac_id", null: false
    t.integer "revenue_ac_id", null: false
    t.integer "stock_ac_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ending_inv_ac_id"], name: "index_item_accountings_on_ending_inv_ac_id"
    t.index ["purchase_ac_id"], name: "index_item_accountings_on_purchase_ac_id"
    t.index ["revenue_ac_id"], name: "index_item_accountings_on_revenue_ac_id"
    t.index ["stock_ac_id"], name: "index_item_accountings_on_stock_ac_id"
  end

  create_table "items", id: :serial, force: :cascade do |t|
    t.integer "accounting_id", null: false
    t.boolean "active", default: true, null: false
    t.decimal "buy_price", precision: 14, scale: 2, default: "0.0", null: false
    t.string "code", limit: 100, null: false
    t.timestamp "created_at", null: false
    t.integer "creator_id", null: false
    t.string "description", null: false
    t.boolean "for_sale", default: true, null: false
    t.string "name", null: false
    t.decimal "price", precision: 14, scale: 2, default: "0.0", null: false
    t.boolean "stockable", default: true, null: false
    t.integer "tag_ids", default: [], array: true
    t.integer "unit_id", null: false
    t.timestamp "updated_at", null: false
    t.integer "updater_id"
    t.index ["accounting_id"], name: "index_items_on_accounting_id"
    t.index ["code"], name: "index_items_on_code", unique: true
    t.index ["creator_id"], name: "index_items_on_creator_id"
    t.index ["unit_id"], name: "index_items_on_unit_id"
    t.index ["updater_id"], name: "index_items_on_updater_id"
  end

  create_table "links", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "api_token"
    t.timestamp "created_at", null: false
    t.boolean "creator", default: false, null: false
    t.boolean "master_account", default: false, null: false
    t.integer "organisation_id", null: false
    t.string "role", limit: 50, null: false
    t.string "settings"
    t.timestamp "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["api_token"], name: "index_links_on_api_token", unique: true
    t.index ["organisation_id"], name: "index_links_on_organisation_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "loans", force: :cascade do |t|
    t.string "bank_name", null: false, comment: "銀行名+支店名"
    t.datetime "created_at", null: false
    t.date "due_date"
    t.decimal "interest_rate", precision: 7, scale: 4, null: false, comment: "percent"
    t.datetime "updated_at", null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer "account_id"
    t.bigint "amount", null: false
    t.decimal "balance", precision: 14, scale: 2, default: "0.0", null: false
    t.timestamp "created_at", null: false
    t.string "description", null: false
    t.integer "item_id"
    t.integer "order_id", null: false
    t.decimal "quantity", precision: 14, scale: 2
    t.timestamp "updated_at", null: false
    t.index ["account_id"], name: "index_order_details_on_account_id"
    t.index ["item_id"], name: "index_order_details_on_item_id"
    t.index ["order_id", "item_id"], name: "index_order_details_on_order_id_and_item_id", unique: true
    t.index ["order_id"], name: "index_order_details_on_order_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.timestamp "approver_datetime"
    t.integer "approver_id"
    t.integer "contact_id"
    t.timestamp "created_at", null: false
    t.integer "creator_id", null: false
    t.string "currency", limit: 3
    t.date "date", null: false
    t.boolean "delivered", default: false, null: false
    t.date "delivery_date"
    t.string "delivery_loc"
    t.boolean "devolution", default: false, null: false
    t.boolean "discounted", default: false, null: false
    t.bigint "gross_total"
    t.string "incoterms", limit: 10
    t.boolean "no_inventory", default: false, null: false
    t.string "null_reason", limit: 400
    t.integer "nuller"
    t.timestamp "nuller_datetime"
    t.integer "prod_item_id"
    t.date "ship_date", comment: "If FOB and *CIF*, the date on the port of departure"
    t.string "state", limit: 50, null: false
    t.integer "store_id"
    t.bigint "total"
    t.integer "trans_to_id"
    t.string "type", limit: 80, null: false
    t.timestamp "updated_at", null: false
    t.index ["contact_id"], name: "index_orders_on_contact_id"
    t.index ["prod_item_id"], name: "index_orders_on_prod_item_id"
    t.index ["store_id"], name: "index_orders_on_store_id"
    t.index ["trans_to_id"], name: "index_orders_on_trans_to_id"
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "address"
    t.string "address_alt"
    t.string "country_code", limit: 2, null: false
    t.timestamp "created_at", null: false
    t.string "currency", limit: 3, null: false
    t.date "due_date"
    t.date "due_on"
    t.string "email"
    t.boolean "inventory_active", default: true
    t.string "mobile", limit: 40
    t.string "name", limit: 100, null: false
    t.string "phone", limit: 40
    t.string "phone_alt", limit: 40
    t.string "plan", default: "2users"
    t.jsonb "settings", null: false
    t.date "stock_fixed_date", null: false
    t.string "tenant", limit: 50, null: false
    t.string "time_zone", limit: 100, null: false
    t.timestamp "updated_at", null: false
    t.string "website"
    t.index ["tenant"], name: "index_organisations_on_tenant", unique: true
  end

  create_table "resources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "res_type", limit: 2, null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_resources_on_name", unique: true
    t.index ["unit_id"], name: "index_resources_on_unit_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.timestamp "created_at", null: false
    t.date "date", null: false
    t.integer "invt_type", limit: 2, null: false
    t.integer "item_id", null: false
    t.decimal "minimum", precision: 14, scale: 2, default: "0.0", null: false, comment: "安全在庫の履歴"
    t.decimal "quantity", precision: 14, scale: 2, null: false
    t.integer "store_id", null: false
    t.decimal "unitary_cost", precision: 14, scale: 2, null: false
    t.timestamp "updated_at", null: false
    t.index ["date", "store_id", "item_id", "invt_type"], name: "index_stocks_on_date_and_store_id_and_item_id_and_invt_type", unique: true
    t.index ["item_id"], name: "index_stocks_on_item_id"
    t.index ["store_id"], name: "index_stocks_on_store_id"
  end

  create_table "stores", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address", null: false
    t.timestamp "created_at", null: false
    t.string "description", null: false
    t.string "name", null: false
    t.string "phone", limit: 40
    t.timestamp "updated_at", null: false
  end

  create_table "tag_groups", force: :cascade do |t|
    t.string "bgcolor"
    t.timestamp "created_at", null: false
    t.string "name"
    t.integer "tag_ids", default: [], array: true
    t.timestamp "updated_at", null: false
    t.index ["name"], name: "index_tag_groups_on_name", unique: true
    t.index ["tag_ids"], name: "index_tag_groups_on_tag_ids"
  end

  create_table "tags", force: :cascade do |t|
    t.string "bgcolor", limit: 10
    t.timestamp "created_at", null: false
    t.string "name"
    t.timestamp "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "taxes", force: :cascade do |t|
    t.string "abbreviation", limit: 20, null: false
    t.timestamp "created_at", null: false
    t.string "name", limit: 100, null: false
    t.decimal "percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.timestamp "updated_at", null: false
  end

  create_table "units", id: :serial, force: :cascade do |t|
    t.timestamp "created_at", null: false
    t.boolean "integer", default: false, null: false
    t.string "name", limit: 100, null: false
    t.string "symbol", limit: 20, null: false
    t.timestamp "updated_at", null: false
    t.boolean "visible", default: true, null: false
    t.index ["symbol"], name: "index_units_on_symbol", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address"
    t.string "auth_token"
    t.boolean "change_default_password", default: false
    t.timestamp "confirmation_sent_at"
    t.string "confirmation_token", limit: 60
    t.timestamp "confirmed_at"
    t.timestamp "created_at", null: false
    t.string "crypted_password"
    t.string "description", limit: 255
    t.string "email", null: false
    t.string "first_name", limit: 80, null: false
    t.string "last_name", limit: 80, null: false
    t.timestamp "last_sign_in_at"
    t.string "locale", default: "en"
    t.string "mobile", limit: 40
    t.text "old_emails", default: [], array: true
    t.string "phone", limit: 40
    t.timestamp "reset_password_sent_at"
    t.string "reset_password_token"
    t.timestamp "reseted_password_at"
    t.string "rol", limit: 50
    t.string "salt"
    t.integer "sign_in_count", default: 0
    t.timestamp "updated_at", null: false
    t.string "website", limit: 200
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "account_ledgers", "accounts"
  add_foreign_key "account_ledgers", "contact_accounts", column: "bp_bank_account_id"
  add_foreign_key "account_ledgers", "contacts", column: "partner_id"
  add_foreign_key "account_ledgers", "inventories"
  add_foreign_key "attachments", "inventories"
  add_foreign_key "attachments", "items"
  add_foreign_key "attachments", "orders"
  add_foreign_key "bom_structures", "items", column: "child_item_id"
  add_foreign_key "bom_structures", "items", column: "parent_id"
  add_foreign_key "bom_structures", "orders", column: "sales_order_id"
  add_foreign_key "bom_structures", "resources", column: "child_res_id"
  add_foreign_key "contact_accounts", "contacts"
  add_foreign_key "inventories", "invoices"
  add_foreign_key "inventories", "orders"
  add_foreign_key "inventories", "stores"
  add_foreign_key "inventory_details", "inventories"
  add_foreign_key "inventory_details", "items"
  add_foreign_key "invoices", "contact_accounts", column: "bp_bank_account_id"
  add_foreign_key "invoices", "contacts", column: "partner_id"
  add_foreign_key "item_accountings", "accounts", column: "ending_inv_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "purchase_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "revenue_ac_id"
  add_foreign_key "item_accountings", "accounts", column: "stock_ac_id"
  add_foreign_key "items", "item_accountings", column: "accounting_id"
  add_foreign_key "items", "units"
  add_foreign_key "links", "organisations"
  add_foreign_key "links", "users"
  add_foreign_key "order_details", "accounts"
  add_foreign_key "order_details", "items"
  add_foreign_key "order_details", "orders"
  add_foreign_key "orders", "contacts"
  add_foreign_key "orders", "items", column: "prod_item_id"
  add_foreign_key "orders", "stores"
  add_foreign_key "orders", "stores", column: "trans_to_id"
  add_foreign_key "resources", "units"
  add_foreign_key "stocks", "items"
  add_foreign_key "stocks", "stores"
end
