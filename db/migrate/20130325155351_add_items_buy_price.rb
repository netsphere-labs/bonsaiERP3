class AddItemsBuyPrice < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.bigint :last_buy_price #, null:false, default: 0.0
        t.column :last_buy_curr, "CHAR(3)"
        t.date   :last_buy_date
      end
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.remove :last_buy_price
        t.remove :last_buy_curr
        t.remove :last_buy_date
      end
    end
  end
end
