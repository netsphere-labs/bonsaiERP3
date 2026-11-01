
# 部門, 品目などの "軸" を表す
class CreateTagGroups < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :tag_groups do |t|
        t.string :name, null:false, index: {unique: true }
        
        t.string :bgcolor, limit:20, null:false
        
        #t.integer :tag_ids, integer: true, array: true, default: []

        t.timestamps
      end

      #add_index :tag_groups, :name, unique: true
      #add_index :tag_groups, :tag_ids #, using: :gin
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      drop_table :tag_groups
    end
  end
end
