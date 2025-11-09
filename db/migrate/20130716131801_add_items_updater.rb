class AddItemsUpdater < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.integer :updater_id
      end

      add_index :items, :updater_id
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      change_table :items do |t|
        t.remove :updater_id
      end
    end
  end
end
