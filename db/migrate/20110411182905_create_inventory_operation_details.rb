class CreateInventoryOperationDetails < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      create_table :inventory_details do |t|
        # 親
        t.references :inventory, type: :integer, null:false, foreign_key:true

        #redundant -> use `operation` field on `inventories`.
        #t.column :movement_type, "SMALLINT NOT NULL"
        
        t.references :item, type: :integer, null:false, foreign_key:true

        # 例えば, 購買入庫で数量違いの場合、取引通貨での金額が必要. nullable
        # 端数を考えると, 単価ではなく, 行金額.
        t.bigint :txn_amount, comment:"取引通貨建ての line amount (if any)"

        # Use `Stock#unitary_cost`
        # 移動平均を考えると、出庫伝票に単価があると、レコードの挿入のたびに、ほかの伝票の単価を変更しなければならない
        #t.decimal :unitary_cost, precision: 14, scale: 2, null:false, default:0.0, comment:"原価 (機能通貨)"

        t.decimal :quantity, precision: 14, scale: 2, null:false

        t.timestamps
      end
      add_index :inventory_details,
                [:inventory_id, :item_id], unique: true
    end
  end
end
