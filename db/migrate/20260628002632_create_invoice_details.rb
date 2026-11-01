
class CreateInvoiceDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_goods do |t|
      # parent
      t.references :invoice, null:false, foreign_key:true

      t.references :item, type: :integer, null:false, foreign_key:true
      t.decimal :qty, precision: 14, scale: 2, null:false
      t.bigint  :txn_amount, null:false, comment: "line amount"

      t.timestamps
    end
  end
end
