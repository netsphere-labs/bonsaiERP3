class CreateInventoryOperations < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      # 入出庫伝票。
      create_table :inventories, id: :serial do |t|
        t.date   :date, null:false
        t.string :ref_number
        t.string :operation, limit: 10, null:false

        t.string "state", limit: 20, null: false

        # sales, purchase, transfer, production order. nullable
        t.references :order, type: :integer, foreign_key:true

        # operation = `exp_in`, `pur_tran`, `inc_out`
        t.references "invoice", type: :integer, foreign_key: true
        
        # 店は必須
        t.references :store, type: :integer, null:false, foreign_key:true

        # sales order なしの出庫は認めない
        #t.references :account, type: :integer, foreign_key:true

        t.string :description, null:false

        # 例えば, 購買入庫で数量違いの場合、取引通貨での金額が必要. -> details 側に持つ
        # nullable
        t.column :curr_code, "CHAR(3)"
        
        t.integer  :creator_id, null:false
        #t.integer  :transference_id

        # Use `TransferRequest#trans_to`
        #t.integer  :store_to_id
        
        #t.references :project, type: :integer, foreign_key:true

        t.boolean :has_error, null:false, default: false
        t.jsonb   :error_messages

        t.timestamps
      end
    end
  end
  
end
