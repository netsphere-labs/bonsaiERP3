# author: Boris Barroso
# email: boriscyber@gmail.com

# Base of SalesOrder and PurchaseOrder
class Order < BusinessRecord 

  # `delivered` = closed
  # `partial`: PO = Partially Received, SO = Partially Fulfilled
  STATES = %w(draft confirmed partial delivered void).freeze

  # Callbacks
  #before_update :check_items_balances

  ########################################
  # Relationships

  has_many :details, -> {order('id ASC')},
           class_name: "MovementDetail", dependent: :destroy

  #accepts_nested_attributes_for :income_details, allow_destroy: true,
  #reject_if: proc { |det| det.fetch(:item_id).blank? }
  
  #belongs_to :project, optional: true
  
  has_many :ledgers, foreign_key: :account_id, class_name: 'AccountLedger'
  
  has_many :inventories #, foreign_key: :account_id

  ########################################
  # Validations
  
  validates_presence_of :date
  
  enum :state, STATES.map{|x| [x,x]}.to_h
  
  validate  :valid_currency_change, on: :update
  validate  :greater_or_equal_due_date

  ########################################
  # Delegations
  delegate :name, :percentage, :percentage_dec, to: :tax, prefix: true, allow_nil: true
  
  def self.movements
    Account.where(type: ['Income', 'Expense'])
  end

  
  ########################################
  # Aliases, alias and alias_method not working
#  [[:ref_number, :name], [:balance, :amount]].each do |meth|
#    define_method meth.first do
#      self.send(meth.last)
#    end

#    define_method :"#{meth.first}=" do |val|
#      self.send(:"#{meth.last}=", val)
#    end
#  end

  
  def to_param
    "#{id}"
  end

  def display_state
    case state
      when 'draft';     "badge text-bg-warning" 
      when 'confirmed'; "badge text-bg-success"
      when 'partial';   "badge text-bg-info"
      when 'delivered'; "badge text-bg-primary"   # closed
      when 'void';      "badge text-bg-dark"  
    end
  end
  
=begin
  def set_state_by_balance!
    if balance <= 0
      self.state = 'paid'
    elsif balance != total
      self.state = 'approved'
    elsif state.blank?
      self.state = 'draft'
    end
  end
=end
  
  def total_discount
    gross_total - total
  end

  def discount_percent
    total_discount / gross_total
  end


  # `save()` must be done by caller.
  def confirm! user
    raise TypeError if !user.is_a?(User)
    
    if draft?
      self.state = 'confirmed'
      self.approver_id = user.id
      self.approver_datetime = Time.zone.now
      #self.due_date ||= Time.zone.now.to_date
      #self.extras = extras.symbolize_keys
    end
  end

  
  # PO: 購買入庫から呼び出される
  def update_state!
    qty_received = 0
    ttl_balance = 0   
    details.each do |det|
      qty_received += (det.quantity - det.balance)
      ttl_balance += det.balance.abs # 過剰と未受領がありえる
    end

    if ttl_balance == 0
      self.state = 'delivered'
    elsif qty_received > 0
      self.state = 'partial'
    end
    
    save!
  end

  
  def null!
    if can_null?
      update(state: 'nulled', nuller_id: UserSession.id, nuller_datetime: Time.zone.now)
    end
  end

=begin
  def can_null?
    return false  if draft? || nulled?
    return false  if ledgers.pendent.any?
    return false  if inventory_was_moved?
    total === amount
  end
=end
  
  def inventory_was_moved?
    details.any? { |det| det.quantity != det.balance }
  end

  
  def can_devolution?
    return false  if is_draft? || is_nulled?
    return false  if balance == total

    true
  end

  def is_active?
    confirmed? || is_paid?
  end

  def taxes
    subtotal * tax_percentage/100
  end

  #alias_method :old_attributes, :attributes
  #def attributes
  #  old_attributes.merge(
  #    Hash[ hstore_metadata_for_extras.keys.map { |key| [key.to_s, self.send(key)] } ]
  #  )
  #end

  
private

  def nulling_valid?
    ['paid', 'confirmed'].include?(state_was) && is_nulled?
  end

    # Do not allow items to be destroyed if the quantity != balance
#    def check_items_balances
#      details.select(&:marked_for_destruction?)
#      .all?(&:valid_for_destruction?)
#    end

   def valid_currency_change
     errors.add(:currency, I18n.t('errors.messages.movement.currency_change'))  if currency_changed? && ledgers.any?
   end

   
  # for validate()
  def greater_or_equal_due_date
    if date && ship_date && !(date <= ship_date)
      errors.add(:ship_date, "must be >= order_date" )
    end

    if ship_date && delivery_date && !(ship_date <= delivery_date)
      errors.add(:delivery_date, "must be >= ship_date" )
    end
  end
  
end
