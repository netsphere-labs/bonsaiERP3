# author: Boris Barroso
# email: boriscyber@gmail.com

# Class that creates "Sales Order"
class SalesOrder < Order

  # TODO: オーダの変更 (納品不足など) の保存
  #include Models::History
  #has_history_details Movements::History, :income_details

  #self.code_name = 'I'
  
  ########################################
  # Relationships

  # 親
  belongs_to :contact

  # ship_from: sales only
  belongs_to :store, optional:true

  has_many :payments, -> { where(operation: 'payin') }, class_name: 'AccountLedger', foreign_key: :account_id

  # what's this?
  #has_many :devolutions, -> { where(operation: 'devout') }, class_name: 'AccountLedger', foreign_key: :account_id

  ########################################
  # Scopes

  scope :active,   -> { where(state: ['approved', 'paid']) }

  # customer
  scope :contact, -> (cid) { where(contact_id: cid) }
  
  scope :pendent, -> { active.where.not(amount: 0) }
  scope :error, -> { active.where(has_error: true) }
  scope :due, -> { approved.where("accounts.due_date < ?", Time.zone.now.to_date) }
  #scope :nulled, -> { where(state: 'nulled') }
  scope :inventory, -> { active.where("extras->'delivered' = ?", 'false') }
  scope :like, -> (search) {
    search = "%#{search}%"
    t = Income.arel_table
    where(t[:name].matches(search).or(t[:description].matches(search) ) )
  }
  scope :date_range, -> (range) { where(date: range) }

  with_options if: :confirmed? do |r|
    r.validates_presence_of :store_id   # ship_from
    r.validates_presence_of :ship_date
  end

  
  def subtotal
    self.income_details.inject(0) {|sum, det| sum += det.total }
  end

  def as_json(options = {})
    super(options).merge(income_details: income_details.map(&:attributes))
  end
end
