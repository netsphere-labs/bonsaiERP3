
class CreateCurrXchgs < ActiveRecord::Migration[8.1]
  def change
    create_table :curr_xchgs do |t|
      t.string "curr_code", limit:3, null:false
      t.date "date", null:false
      t.float "rate", null:false
      
      t.timestamps
    end
    add_index :curr_xchgs, [:date, :curr_code], unique: true
  end
end
