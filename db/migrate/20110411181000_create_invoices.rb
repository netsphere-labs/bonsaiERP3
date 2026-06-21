
class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    # purchase invoice / sales invoice
    create_table :invoices do |t|
      # parent
      t.references :partner, null:false, foreign_key: {to_table: :contacts}

      t.string :inv_type, limit:10, null:false
      
      t.date :date, null:false
      t.string "doc_no" #, null: false
      
      # only pur-inv. nullable
      t.references :bp_bank_account, foreign_key: {to_table: :contact_accounts}

      t.date :due_date, null:false

      t.bigint :amount_total, null:false
      t.string :curr_code, limit: 3, null:false

      t.integer "lock_version", null: false
      t.string "status", limit: 20, null: false

      t.timestamps
    end
    add_index :invoices, [:partner_id, :doc_no], unique:true
  end
end
