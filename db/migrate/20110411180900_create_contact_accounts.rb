
# 取引先の bank account. 
class CreateContactAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_accounts do |t|
      # 親
      t.references :contact, type: :integer, null:false, foreign_key:true

      # NOT NULL
      t.string :bank_name, null:false, comment: "銀行名+支店名"
      t.string :bank_addr
      
      # たまたま別銀行で口座番号が一致する、のは考えない
      t.string :account_no, null:false, index: {unique:true}
      t.string :account_name, null:false
      
      t.timestamps
    end
    #add_index :contact_accounts, [:contact_id, :account_no], unique:true
  end
end
