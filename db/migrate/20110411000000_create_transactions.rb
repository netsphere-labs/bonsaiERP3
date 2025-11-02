class CreateTransactions < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      create_table :orders, id: :serial do |t|
        # STI は `type` が必要
        t.string :type, limit:80, null:false

        # order_date: datetime はやりすぎ。`date` で十分
        t.date :date, null:false

        # purchase order: vendor NOT NULL
        # sales order: customer NOT NULL
        # trans / prod order: nullable
        t.references :contact, type: :integer, foreign_key:true

        # purchase order: ship_to (NOT NULL), sales order: ship_from (nullable).
        t.references :store, type: :integer, foreign_key: true

        # trans. request
        t.references :trans_to, type: :integer, foreign_key:{to_table:'stores'}

        t.references :prod_item, type: :integer, foreign_key: {to_table:'items'}
        
        # before discount
        t.decimal :gross_total, precision: 14, scale: 2, default: 0.0

        # after discount
        # Use Account#amount for total, create alias
        t.decimal :total, precision: 14, scale: 2, null:false, default: 0.0

        t.column :currency, "CHAR(3) NOT NULL"

        # Use Account#name for ref_number create alias
        t.string  :bill_number

        t.decimal :original_total, precision: 14, scale: 2, default: 0.0
        t.decimal :balance_inventory, precision: 14, scale: 2, default: 0.0

        # PO: When D-group, ship_date = delivery_date
        # SO: ship_date nullable
        t.date    :ship_date, #null:false,
                  comment: "If FOB and *CIF*, the date on the port of departure"

        # if any. "TOKYO CY", "LONG BEACH CY"
        t.string  :delivery_loc
        
        t.string  :incoterms, limit:10
        
        # sales_order: nullable
        t.date    :delivery_date #, null:false
        
        # Creators approver
        t.integer  :creator_id, null:false #, foreign_key:{to_table: :users}
        t.integer  :approver_id  #, foreign_key:{to_table: :users}
        t.datetime :approver_datetime
        
        t.integer  :nuller #, foreign_key:{to_table: :users}
        t.datetime :nuller_datetime
        t.string   :null_reason, limit: 400

        t.boolean :delivered, null:false, default: false
        t.boolean :discounted, null:false, default: false
        t.boolean :devolution, null:false, default: false

        t.string :state, limit:50, null:false
        
        t.timestamps
      end

      #add_index :transactions, :account_id, unique: true
      #add_index :transactions, :due_date
      #add_index :transactions, :delivered
      #add_index :transactions, :discounted
      #add_index :transactions, :devolution
      #add_index :transactions, :bill_number
    end
  end
end
