
# 消費税 / VAT
class CreateTaxes < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :taxes do |t|
        t.column :country_code, "CHAR(2) NOT NULL"
        
        t.string :name, limit: 100, null:false
        t.string :abbreviation, limit: 20, null:false
        t.decimal :percentage, precision: 5, scale: 2, null:false 

        t.timestamps
      end
    end
  end
end
