
# author: Boris Barroso
# email: boriscyber@gmail.com

# Purchase Order
class PurchaseOrder < Order

  # TODO: change order
  #include Models::History
  #has_history_details Movements::History, :expense_details

  ########################################
  # Relationships
  
  # 親
  belongs_to :contact

  has_many :payments, -> { where(operation: 'payout') },
           class_name: 'AccountLedger', foreign_key: :account_id
  has_many :devolutions, -> { where(operation: 'devin') },
           class_name: 'AccountLedger', foreign_key: :account_id

  # ship_to: purchase only, NOT NULL
  belongs_to :store

  
  # Validations ##############################################
  
  validates_presence_of :ship_date

  validates_presence_of :gross_total
  validates_presence_of :total
  validates_presence_of :currency
  #validates_inclusion_of :currency, in: CURRENCIES.keys
  
  before_validation :set_delivery_date

  
  ########################################
  # Scopes
  
  # vendor
  #scope :contact, -> (cid) { where(contact_id: cid) }
  
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  #scope :due, -> { approved.where("accounts.due_date < ?", Time.zone.now.to_date) }
  
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (s) {
    s = "%#{s}%"
    t = Expense.arel_table
    where(t[:name].matches(s).or(t[:description].matches(s) ) )
  }
  scope :date_range, -> (range) { where(date: range) }

  def subtotal
    expense_details.inject(0) { |sum, det| sum += det.total }
  end

  def as_json(options = {})
    super(options).merge(expense_details: expense_details.map(&:attributes))
  end

  
private

  # for `before_validation()`
  def set_delivery_date
    self.delivery_date = ship_date if !delivery_date
  end

end
