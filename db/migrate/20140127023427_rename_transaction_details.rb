class RenameTransactionDetails < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      rename_table :transaction_details, :movement_details
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      rename_table :movement_details, :transaction_details
    end
  end
end
