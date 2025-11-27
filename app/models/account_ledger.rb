
# author: Boris Barroso
# email: boriscyber@gmail.com

# 仕訳の半分. 一つの仕訳ごとに2行以上
class AccountLedger < ApplicationRecord

  #include ::Models::Updater
  #extend Models::AccountCode

  #self.code_name = 'T'

  ########################################
  # Constants

  OPERATIONS = ['trans',  # trans  = Transfer from one account to other
                'payin',  # payin  = Payment in Income, adds ++
                'payout', # payout = Paymen out Expense, substracts --
                'devin',  # devin  = Devolution in Income, adds --
                'devout', # devout = Devolution out Expense, substracts ++
                'lrcre',  # lrcre  = Create the ledger Loans::Receive, adds ++
                'lrpay',  # lrpay  = Loans::Receive make a payment, substracts --
                'lrint',  # lrint  = Interest Loans::Receive --
                #'lrdev',  # lrdev  = Loans::Receive make a devolution, adds ++
                'lgcre',  # lgcre  = Create the ledger Loans::Give, substract --
                'lgpay',  # lgpay  = Loans::Give receive a payment, adds ++
                'lgint',  # lgint  = Interests for Loans::Give ++
                #'lgdev',  # lgdev  = Loans::Give make a devolution, substract --
                'servex', # servex = Pays an account with a service account_to is Expense
                'servin', # servin = Pays an account with a service account_to is Income
               ].freeze

  # 仕訳は基本 `approved` で作る. `pendent` は仮仕訳
  STATUSES = %w(pendent approved void).freeze

  ########################################
  # Callbacks
  
  #before_validation :set_currency
  #before_create :set_code

  # Includes
  include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships

  # 勘定科目
  belongs_to :account
  
  # 人名勘定で行くので, 逆に contact はなし.
  #belongs_to :contact, optional: true
  
  belongs_to :project, optional:true
  
  belongs_to :approver, class_name: 'User', optional:true
  belongs_to :nuller,   class_name: 'User', optional:true
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User', optional:true

  ########################################
  # Validations
  
  validates_presence_of :amount, :currency
  validates_presence_of :date
  #validate :different_accounts

  validates_inclusion_of :operation, in: OPERATIONS

  #validates_inclusion_of :status, in: STATUSES
  enum :status, STATUSES.map{|x| [x,x]}.to_h
       
  validates_numericality_of :exchange_rate, greater_than: 0
  #validates_presence_of :contact_id, unless: :is_trans?
  #validates :reference,
  #          length: { within: 3..300, allow_blank: false }

  validates_lengths_from_database

  ########################################
  # scopes, optional: true, optional: true
  #scope :pendent, -> { where(status: 'pendent') }
  #scope :nulled,  -> { where(status: 'nulled') }
  #scope :approved, -> { where(status: 'approved') }
  
  scope :active, -> { where(status: ['pendent', 'approved']) }

  ########################################
  # delegates
  
  #delegate :name, :amount, :contact, :contact_id,
  #         to: :account, prefix: true, allow_nil: true
  #delegate :name, :amount, :currency, :contact,
  #         to: :account_to, prefix: true, allow_nil: true
  delegate :same_currency?, to: :currency_exchange

  OPERATIONS.each do |op|
    define_method :"is_#{op}?" do
      op == operation
    end
  end

  STATUSES.each do |st|
    define_method :"is_#{st}?" do
      st == status
    end
  end

  #def to_s
  #  name
  #end

  # Determines if the ledger can be conciliated or nulled
  def can_conciliate_or_null?
    !(nuller_id.present? || approver_id.present?)
  end

  def amount_currency
    currency_exchange.exchange(amount)
  end

  def save_ledger
    if is_approved?
      ConciliateAccount.new(self).conciliate!
    else
      save
    end
  end

  def update_reference(txt)
    self.reference = txt

    save
  end

  
private

    def currency_exchange
      @currency_exchange ||= CurrencyExchange.new(
        account: account, account_to: account_to, exchange_rate: exchange_rate
      )
    end

  # 取引の通貨は, 勘定科目の通貨とは限らない
  #  def set_currency
  #    self.currency = account_to_currency
  #  end

    #def set_creator
    #  self.creator_id = UserSession.id
    #end

  #def set_code
  #    self.name = self.class.get_code_number
  #  end

    #def set_approver
    #  self.approver_id = UserSession.id
    #end

    def different_accounts
      if account_id == account_to_id
        errors[:account_to_id] << I18n.t('errors.messages.account_ledger.same_account')
      end
    end

end
