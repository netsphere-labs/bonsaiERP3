
# それぞれのタグの値
class CreateTags < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :tags do |t|
        # parent
        t.references :tag_group, null:false, foreign_key:true
        
        t.string :name, null:false, index: {unique:true}

        # override
        t.string :bgcolor, limit: 20

        t.timestamps
      end

      #add_index :tags, :name
    end
  end
end
