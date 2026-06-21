class CreateUnits < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :units, id: :serial do |t|
        t.string :name, limit: 100, null:false
        t.string :symbol, limit: 20, null:false, index: {unique:true}
        
        t.boolean :integer, null: false, default: false
        t.boolean :visible, null: false, default: true

        t.timestamps
      end
    end
  end
end
