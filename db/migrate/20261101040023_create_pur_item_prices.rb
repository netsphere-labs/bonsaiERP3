
class CreatePurItemPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :pur_item_prices do |t|
      # dim
      t.references :item, type: :integer, null:false, foreign_key: true

      # dim
      t.references :partner, type: :integer, null:false, foreign_key: {to_table:"contacts"}

      # dim
      t.column :currency, "CHAR(3) NOT NULL"

      # ex) If min_qty = 1,000, you can not order it under 1,000 EA.
      t.decimal "min_qty", precision: 14, scale: 2, null: false

      t.bigint :buy_price, null:false

      # TODO: effective date
      
      t.timestamps
    end
  end
end
