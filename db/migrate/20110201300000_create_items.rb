
class CreateItems < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      # product items
      create_table :items, id: :serial do |t|
        t.string  :code, limit: 100, null:false, index: {unique: true}

        # UoM
        t.references :unit, type: :integer, null:false, foreign_key:true

        # 個々の item に設定はやりすぎ
        #t.references :account, type: :integer, null:false, foreign_key:true

        # current price. 銭の単位まで持つ
        t.decimal :price, precision: 14, scale: 2, null:false, default: 0.0
        
        t.string  :name, null:false
        t.string  :description, null:false
        t.boolean :for_sale, null:false, default: true
        t.boolean :stockable, null:false, default: true
        t.boolean :active, null:false, default: true

        t.timestamps
      end
    end
  end
end
