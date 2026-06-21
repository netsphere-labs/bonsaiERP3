
# author: Boris Barroso
# email: boriscyber@gmail.com

# 勘定科目マスタ. マスタに見えないが, マスタ.
#
# 次のようにレコードを作る. Cash だけ作ると, Account ができない.
#   x = Account.new accountable: Cash.new()
# puts x.attributes
# puts x.cash.attributes
#
# クエリは, 次のようにすれば、Cash と紐づく Account だけ取ってくれる
# 勝手に "accountable_type" = 'Cash' を補ってくれる
#   Cash.eager_load(:account)
#
class Account < ApplicationRecord
  #include ActionView::Helpers::NumberHelper
  include ::Models::Tag

  
  ########################################
  # Relationships

  # DB schema: accountable_type, accountable_id
  # 親レコードの削除に合わせて子レコードも削除するには dependent: :destroy
  delegated_type :accountable, optional: true, dependent: :destroy,
                 types: %w[Cash Loan]
  # 次はサブクラスでオーバライドする場合の書き方
  #delegate :name, to: :accountable
  
  has_many :account_ledgers, -> { order('date desc, id desc') }
  
  belongs_to :nuller,   class_name: 'User', optional: true
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User', optional: true

  # 不課税は nil
  belongs_to :tax, optional: true

  before_validation :update_name

  
  ########################################
  # Validations
  
  validates_presence_of :name
  validates_uniqueness_of :name

  with_options if: ->{ ['A:CASH', 'A:AR', 'L:AP'].include?(subtype) } do |r|
    r.validates_presence_of :currency
  end
  validates :currency, format: {with: /\A[A-Z][A-Z][A-Z]\z/}, allow_nil: true

  # TODO: `account_types` 表で設定可能にする
  SUBTYPES = {
    # Assets / Liabilities
    'A:CASH'  => 'assets:Cash and Bank Account',
    'A:AR'    => 'assets:Accounts Receivable',
    'A:INV'   => 'assets:Inventory',  # stock は完成品のみ, inventory は材料も含むイメージ
    'A:OTHER' => 'assets:Other',
    
    'L:AP'    => 'liabilities:Accounts Payable',
    'L:OTHER' => 'liabilities:Other',

    'EQUITY'  => 'Equity',
    
    # P/L
    'REV'           => 'Revenue',
    'OP:VC'         => 'OP:Variable Cost',
    'OP:OTHER-INCOME' => 'OP:Other Income',
    'OP:NON-VC'     => 'OP:Non-Variable Costs',
    'INVEST:GAIN-LOSS' => 'INVEST:評価損益・売却損益',
    'FIN:INTEREST'  => 'FIN:利息',
    'INCOME-TAX'    => 'Income Tax'
  }
  validates_inclusion_of :subtype, in: SUBTYPES.keys
  
  validates_lengths_from_database

  # attribute
  # Rails 7.1 での非互換変更: 第2引数に `coder:` が必要.
  # See https://techracho.bpsinc.jp/hachi8833/2023_03_14/128066
  #serialize :error_messages, coder: JSON

  ########################################
  # Scopes, optional: true, optional: true
  
  scope :active, -> { where(active: true) }
  scope :money, -> { where(type: %w(Bank Cash)) }
  scope :in, -> { where(type: %w(Income Loans::Give)) }
  scope :out, -> { where(type: %w(Expense Loans::Receive)) }

  #delegate :name, :code, :symbol, to: :curr, prefix: true

  ########################################
  # Methods
  #def to_s
  #  name
  #end

  #def curr
  #  @curr ||= Currency.find(currency)
  #end

  
private
  
  # for `before_validation()`
  # `Account` の側が参照するので, こちらに仕込む
  def update_name
    self.currency = nil if currency.blank?
  end
  
end
