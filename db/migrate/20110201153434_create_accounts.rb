
class CreateAccounts < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do
      # 勘定科目マスタ.
      # マスタっぽくないフィールドが大量にあるが, マスタのはず.
      create_table :accounts, id: :serial do |t|
        t.string  :name, null:false, index: {unique:true}

        # 通貨は勘定科目ごとに持つ。restriction
        # 現金預金と債権債務以外は, 通貨不要. nullable.
        t.column  :currency, "CHAR(3) "
        
        t.string  :description, limit: 500, null:false

        # delegated_type (= polymorphic) にする. nullable
        t.string :accountable_type, limit:80 #, null:false
        t.integer :accountable_id #, null:false

        # 売上, 変動費, 非変動費, ...
        t.string :subtype, limit:40, null:false
        
        # この意味?
        #t.string  :state, limit: 30
        t.boolean :active, null:false, default: true
        
        t.boolean :has_error, null:false, default: false
        t.jsonb   :error_messages #, limit: 400

        t.timestamps
      end
      add_index :accounts, [:accountable_type, :accountable_id], unique:true
    end
  end
end
