
# Machine, Labor, Other rates
class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.column :res_type, "SMALLINT NOT NULL"

      t.string :name, null:false, index: {unique:true}
      t.references :unit, null:false, foreign_key: true
      
      t.timestamps
    end
  end
end
