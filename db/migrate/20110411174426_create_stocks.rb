
class CreateStocks < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :stocks do |t|
        t.date :date, null:false
        
        t.references :store, type: :integer, null:false, foreign_key:true
        t.references :item, type: :integer, null:false, foreign_key:true
        
        t.column :invt_type, "SMALLINT NOT NULL"
        
        t.decimal :unitary_cost, :precision => 14, :scale => 2, null:false, default: 0.0

        # on-hand stock
        t.decimal :quantity, :precision => 14, :scale => 2, null:false, default: 0.0

        # 安全在庫の履歴を持つ
        t.decimal :minimum, :precision => 14, :scale => 2, null:false, default: 0.0, comment: "安全在庫の履歴"
        #t.integer :user_id

        t.timestamps
      end
      add_index :stocks, [:date, :store_id, :item_id, :invt_type], unique:true
      
    end
  end
end
