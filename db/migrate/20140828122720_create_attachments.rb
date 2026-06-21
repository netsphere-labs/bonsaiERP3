class CreateAttachments < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      create_table :attachments do |t|
        #t.string :attachment_uid
        t.string :name, null:false

        # attach to. one of:
        t.references :item, foreign_key:true
        t.references :order, foreign_key:true
        t.references :inventory, foreign_key:true
        
        #t.integer :attachable_id
        #t.string :attachable_type
        
        # created by
        t.integer :user_id, null:false
        
        t.integer :position, null:false

        # Shrine metadata
        t.jsonb :image_data

        t.timestamps
      end

      #add_index :attachments, [:attachable_id, :attachable_type]
      #add_index :attachments, :user_id
      #add_index :attachments, :image
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :attachments, [:attachable_id, :attachable_type]
      remove_index :attachments, :image
      drop_table :attachments
    end
  end
end
