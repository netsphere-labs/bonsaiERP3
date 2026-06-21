
# author: Boris Barroso
# email: boriscyber@gmail.com

# 仕訳の半分. 一つの仕訳ごとに2行以上
class AccountLedger < ApplicationRecord

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

  #validates_inclusion_of :status, in: STATUSES
  enum :status, STATUSES.map{|x| [x,x]}.to_h

  scope :active, -> { where(status: ['pendent', 'approved']) }

  
  ########################################
  # Callbacks
  
  #before_create :set_code

  # Includes
  #include ActionView::Helpers::NumberHelper

  ########################################
  # Relationships

  # 勘定科目
  belongs_to :account
  
  belongs_to :partner, class_name:"Contact", optional: true
  belongs_to :bp_bank_account, class_name:"ContactAccount", optional: true
  
  belongs_to :project, optional:true
  
  belongs_to :approver, class_name: 'User', optional:true
  belongs_to :nuller,   class_name: 'User', optional:true
  belongs_to :creator,  class_name: 'User'
  belongs_to :updater,  class_name: 'User', optional:true

  # dummy for form object
  attribute :dr_amt, :string
  attribute :cr_amt, :string
  
  
  ########################################
  # Validations

  validates_presence_of :date, :entry_no

  # Transaction amount & currency: nullable.
  validates_presence_of :fx_curr_code,
                        if: -> r { r.fx_amount && r.fx_amount != 0}
  validates :fx_curr_code, format: {with: /\A[A-Z][A-Z][A-Z]\z/}, allow_nil: true

  # NOT NULL
  validates_presence_of :funct_amount
  
  validates_inclusion_of :operation, in: OPERATIONS
      
  #validates_presence_of :contact_id, unless: :is_trans?
  #validates :reference,
  #          length: { within: 3..300, allow_blank: false }

  validates_lengths_from_database

  validate :check_amount

  
  ########################################
  # delegates
  
  #delegate :name, :amount, :contact, :contact_id,
  #         to: :account, prefix: true, allow_nil: true
  #delegate :name, :amount, :currency, :contact,
  #         to: :account_to, prefix: true, allow_nil: true
  #delegate :same_currency?, to: :currency_exchange

  OPERATIONS.each do |op|
    define_method :"is_#{op}?" do
      op == operation
    end
  end


  # Determines if the ledger can be conciliated or nulled
  def can_conciliate_or_null?
    !(nuller_id.present? || approver_id.present?)
  end

  #def amount_currency
  #currency_exchange.exchange(amount)
  #end

  def save_ledger
    if is_approved?
      ConciliateAccount.new(self).conciliate!
    else
      save
    end
  end

  
private

    #def currency_exchange
    #  @currency_exchange ||= CurrencyExchange.new(
    #    account: account, account_to: account_to, exchange_rate: exchange_rate
    #  )
    #end

  # for `validate()`
  def check_amount
    if fx_amount && fx_amount != 0
      # "0".sign => +1, "-0".sign => -1
      errors.add(:funct_amount, "sign mismatch") if fx_amount.positive? != funct_amount.positive?
    end
  end
  


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
