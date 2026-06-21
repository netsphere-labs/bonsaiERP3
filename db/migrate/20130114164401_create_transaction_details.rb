
# order の 1行
class CreateTransactionDetails < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :order_details do |t|
        # parent
        t.references :order, type: :integer, null:false, foreign_key:true

        # 仕入れかサービスかどちらか. nullable
        t.references :item, type: :integer, foreign_key:true
        t.references :account, type: :integer, foreign_key:true

        # item の場合 qty 必須. 
        t.decimal :quantity, precision: 14, scale: 2

        # line amount. unit price <- amount / qty
        t.bigint :amount, null:false
        
        t.string :description, null:false
        
        #t.decimal :discount, :precision => 14, :scale => 2, default: 0.0

        # 最初: balance = qty, 納品完了: balance = 0
        # なので, 伝票内で item は unique でないといけない
        t.decimal :balance, precision: 14, scale: 2, null:false, default: 0.0

        t.timestamps
      end
      add_index :order_details, [:order_id, :item_id], unique:true
    end
  end
end
