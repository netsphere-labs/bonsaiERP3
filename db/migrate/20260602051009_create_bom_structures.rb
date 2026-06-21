
# BoM
class CreateBomStructures < ActiveRecord::Migration[8.1]
  def change
    create_table :bom_structures do |t|
      t.references :parent, null:false, foreign_key:{to_table: :items}

      t.column :child_type, "SMALLINT NOT NULL"

      # nullable
      t.references :sales_order, foreign_key: {to_table: :orders}
                   
      # oneOf:
      t.references :child_item, foreign_key:{to_table: :items}
      t.references :child_res, foreign_key:{to_table: :resources}
      t.string     :text

      t.decimal :qty, precision:14, scale:2, null:false
      
      t.timestamps
    end
  end
end
