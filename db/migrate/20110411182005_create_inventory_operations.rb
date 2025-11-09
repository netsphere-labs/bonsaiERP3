class CreateInventoryOperations < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      # 入出庫伝票。
      create_table :inventories, id: :serial do |t|
        t.date   :date, null:false
        t.string :ref_number
        t.string :operation, limit: 10, null:false

        t.string "state", limit: 50, null: false

        # sales, purchase, transfer, production order. nullable
        t.references :order, type: :integer, foreign_key:true

        # 店は必須
        t.references :store, type: :integer, null:false, foreign_key:true

        # sales order なしの出庫 = 売上科目
        t.references :account, type: :integer, foreign_key:true

        t.string :description, null:false

        t.decimal :total, :precision => 14, :scale => 2, null:false, default: 0, comment: "機能通貨建ての金額"

        t.integer  :creator_id, null:false
        #t.integer  :transference_id
        t.integer  :store_to_id
        
        #t.references :project, type: :integer, foreign_key:true

        t.boolean :has_error, null:false, default: false
        t.jsonb   :error_messages

        t.timestamps
      end
    end
  end
  
end
