=begin
例えば, 勘定科目は円で, 外貨債務の支払いがある。
平均レート = 120
  Expense  /            100USD   12,000JPY @120 
           / AP(USD)    100USD   12,000JPY @120

平均レート = 110
  AP(USD)  /            100USD   12,000JPY @120 債務のレートを維持
           / CASH(JPY) 7,500JPY●  7,500JPY @1.0 平均レートではなく、その当日レート
           / CASH(USD)   50       5,500    @110
  fx_loss  /            n/a       1,000JPY  n/a

  -> ・仕訳ごとに換算を確定させる必要がある。
     ・行ごとに換算済みフラグを入れれば、各行は後から再換算可能だが、
　　 　為替差損益の行も追加で動く -> 差で追加調整が必要.
         -> まぁまぁ大変

個別銘柄の有価証券の売買
平均レート = 120
  AA社株式 /             10株@12.5USD  15,000JPY @1500
             CASH(USD)   125USD        15,000JPY @120
平均レート = 90
            / AA社株式    5株          7,500JPY @1500   
  CASH(USD) /            100USD       9,000JPY @90
            / gain       0.0          1,500JPY n/a  為替部分は、有価証券の売買益に含めて計算
=end

                                                         
class CreateAccountLedgers < ActiveRecord::Migration[5.2]
  def up
    PgTools.with_schemas except: 'common' do

      # 仕訳の1行. 仕訳は2行以上
      create_table :account_ledgers do |t|
        t.date :date, null:false
        t.integer :entry_no, null:false
        
        t.string   :reference
        t.string   :operation, limit: 20, null:false

        t.references :account, type: :integer, null:false, foreign_key:true
        t.references :partner, type: :integer, foreign_key:{to_table: :contacts}
        t.references :bp_bank_account, type: :integer, foreign_key:{to_table: :contact_accounts}
        
        # 照合済みフラグ。TODO: 相手IDのほうがよい -> many-to-many
        #t.boolean :conciliation, null:false, default: true

        # 取引金額, 取引通貨 don't balance in the slip.
        # nullable
        t.bigint :fx_amount, comment: "借方がプラス"
        t.column  :fx_curr_code, "CHAR(3)", comment: "取引通貨"

        # 機能通貨への換算
        # in functional currency, NOT NULL. MUST balance in the slip.
        t.bigint :funct_amount, null:false

        t.string  :description, null:false

        t.integer  :creator_id, null:false  # related with created_at
        t.integer  :approver_id
        t.datetime :approver_datetime # conciliation
        t.integer  :nuller_id
        t.datetime :nuller_datetime # null
        #t.boolean  :active, null:false, default: true
        t.boolean  :inverse, null:false, default: false

        t.boolean :has_error, null:false, default: false
        t.jsonb   :error_messages

        # TODO: 文字列は効率が悪い.
        t.string  :status, limit: 20, null:false, default: 'approved'

        # nullable
        #t.references :project, type: :integer, foreign_key: true

        # goods receipt PO, delivery. nullable
        t.references :inventory, type: :integer, foreign_key: true
        
        t.timestamps
      end
    end
  end
  
end
