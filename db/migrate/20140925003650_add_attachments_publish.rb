class AddAttachmentsPublish < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      add_column :attachments, :publish, :boolean, null:false, default: false
      #add_index :attachments, :publish
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      remove_index :attachments, :publish
      remove_column :attachments, :publish
    end
  end
end
