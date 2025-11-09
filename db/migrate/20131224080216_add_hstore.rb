class AddHstore < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION hstore SCHEMA public"
  end

  def down
    execute 'DROP EXTENSION IF EXISTS hstore'
  end
end
