class CreateInventoryOperationDetails < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      create_table :inventory_details do |t|
        # 親
        t.references :inventory, type: :integer, null:false, foreign_key:true

        t.column :movement_type, "SMALLINT NOT NULL"
        
        t.references :item, type: :integer, null:false, foreign_key:true
        
        t.decimal :price, precision: 14, scale: 4, null:false, default: 0.0, comment:"機能通貨建ての単価"

        t.references :store, type: :integer, null:false, foreign_key:true

        t.decimal :quantity, precision: 14, scale: 2, null:false, default: 0.0

        t.timestamps
      end
      add_index :inventory_details,
                [:inventory_id, :item_id], unique: true
    end
  end
end
