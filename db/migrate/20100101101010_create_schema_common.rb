class CreateSchemaCommon < ActiveRecord::Migration[5.2]
  def up
    PgTools.create_schema 'common' unless PgTools.schema_exists?('common')
  end

  def down
    PgTools.drop_schema 'common'
  end
end
