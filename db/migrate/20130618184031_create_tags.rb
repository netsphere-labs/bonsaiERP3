class CreateTags < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :tags do |t|
        t.string :name
        t.string :bgcolor, limit: 10

        t.timestamps
      end

      add_index :tags, :name
    end
  end
end
