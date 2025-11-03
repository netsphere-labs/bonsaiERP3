
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
  include ActionView::Helpers::NumberHelper
  include ::Models::Tag
  #include ::Models::Updater
  
  ########################################
  # Relationships

  # schema: accountable_type, accountable_id
  delegated_type :accountable, types: %w[Cash ContactAccount Loan],
                 optional: true
  # 次はサブクラスでオーバライドする場合の書き方
  #delegate :name, to: :accountable
  
  has_many :account_ledgers, -> { order('date desc, id desc') }
  
  #belongs_to :approver, class_name: 'User', optional: true
  belongs_to :nuller,   class_name: 'User', optional: true
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User', optional: true
  belongs_to :tax, optional: true
  
  ########################################
  # Validations
  
  validates_presence_of :name
  validates_uniqueness_of :name

  with_options if: ->{ ['CASH', 'APAR'].include?(subtype) } do |r|
    r.validates_presence_of :currency
    r.validates_inclusion_of :currency, in: CURRENCIES.keys
  end

  # TODO: `account_types` 表で設定可能にする
  SUBTYPES = {
    # Assets / Liabilities
    'CASH' => 'Assets:Cash and Bank Account',
    'APAR' => 'Accounts Payable and Receivable',
    'INV' => 'Assets:Inventory',  # stock は完成品のみ, inventory は材料も含むイメージ

    # P/L
    'REV' => 'Revenue',
    'VC' => 'Expenses:Variable Cost',
    'NON-VC' => 'Expenses:Non-Variable Costs',
    'INTEREST' => '利息',
    'GAIN_LOSS' => '評価損益・売却損益'
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

  delegate :name, :code, :symbol, to: :curr, prefix: true

  ########################################
  # Methods
  def to_s
    name
  end

  def curr
    @curr ||= Currency.find(currency)
  end
end
