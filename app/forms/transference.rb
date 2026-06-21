
# author: Boris Barroso
# email: boriscyber@gmail.com

# form object for 振替伝票, 会計仕訳
class Transference < BaseForm
  # Array of AccountLedger
  attribute :lines, array: true

  attribute :date, :date
  attribute :entry_no, :integer
  attribute :operation, :string
  attribute :reference, :string
  attribute :status, :string


  # Validations #####################################################

  validates_presence_of :date
  validates_presence_of :entry_no
  validates_presence_of :operation
  validates_presence_of :status
  
  validate :valid_accounts_currency


  # Initializes array.
  def initialize ledgers 
    raise TypeError if !ledgers || !ledgers.respond_to?(:each)
    super()

    #self.verification = false unless [true, false].include?(verification)
    self.lines = ledgers
    if !ledgers.empty?
      self.date     = ledgers.first.date
      self.entry_no = ledgers.first.entry_no
    end
  end


  def assign model_params, entries_params, funct_curr
    self.date      = model_params[:date]
    self.reference = model_params[:reference]

    self.lines = self.class.create_je_lines_from_params(entries_params, funct_curr)
  end

  
  # The caller must initiate a transaction.
  def save! user
    # none of model_obj
    
    lines.each_with_index do |je_line, i|
      je_line.assign_attributes creator_id: user.id,
                                updater_id: user.id,
                                date:      self.date,
                                entry_no:  self.entry_no,
                                operation: self.operation,
                                reference: self.reference, # nullable
                                status:    self.status
    end

    if !self.valid?
      raise ActiveRecord::RecordInvalid.new(self)
    end
    
    # all replace of entries
    AccountLedger.where(entry_no: self.entry_no).delete_all

    lines.each do |je_line| je_line.save! end
  end

  
  ######################################################################
  # Class Methods

  # @param line_params [Hash of Hash]  {"0" => {account_id: ...}, "1" => ...}
  # @return [Array of AccountLedger] 
  def self.create_je_lines_from_params line_params, funct_curr
    raise TypeError if !line_params.respond_to?(:keys)

    ret_ary = []
    last_ac = nil
    line_params.each do |lineno_, line|
      last_ac = line[:account_id] if line[:account_id].to_i != 0
      ac = Account.find(last_ac)

      fx_amt, curr, funct_amt, dr_or_cr = parse_amount(line, funct_curr)
      next if !funct_amt
      
      je_line = AccountLedger.new(
                    line.permit(:partner_id, :description, :bp_bank_account_id,
                                :dr_amt, :cr_amt))
      je_line.assign_attributes(account_id: ac.id,
                                fx_amount: fx_amt,
                                fx_curr_code: curr,
                                funct_amount: funct_amt )
      ret_ary << je_line
    end

    return ret_ary
  end


  def self.parse_amount(line, funct_curr)
    if !line[:dr_amt].blank?
      return [nil, nil, nominal_amount(line[:dr_amt], funct_curr), +1]  
    elsif !line[:cr_amt].blank?
      return [nil, nil, -nominal_amount(line[:cr_amt], funct_curr), -1]
    else
      return [nil, nil, nil, 0]
    end
  end
  
  
private

=begin
  # Builds and AccountLedger instance with some default data
  def build_ledger
      AccountLedger.new(
        account_id: account_id, exchange_rate: conv_exchange_rate,
        account_to_id: account_to_id, inverse: inverse?, operation: 'trans',
        reference: reference, date: date,
        currency: account_to.currency,
        status: get_status,
        amount: amount_exchange
      )
    end
=end


    def currency_exchange
      @currency_exchange ||= CurrencyExchange.new(
        account: account, account_to: account_to, exchange_rate: exchange_rate
      )
    end

    def amount_exchange
      if inverse?
        amount * exchange_rate
      else
        amount / exchange_rate
      end
    end

    # Exchange rate used using inverse
    def conv_exchange_rate
      currency_exchange.exchange_rate
    end


    def get_status
      if verification? && any_bank_acccount?
        'pendent'
      else
        'approved'
      end
    end


  # for `validate()`
  def valid_accounts_currency
    if !lines || lines.empty?
      self.errors.add :lines, "entries must have at least one item"
    end
  end
  
end
