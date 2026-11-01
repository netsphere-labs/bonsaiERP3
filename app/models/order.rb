# author: Boris Barroso
# email: boriscyber@gmail.com

# Base of `SalesOrder`, `CustomerReturnRequest`,
#         `PurchaseOrder`, `GoodsReturnRequest`,
#         `TransferRequest` and `ProdOrder`
class Order < BusinessRecord
  # table `orders`
  #self.abstract_class = true

  # `delivered` = closed
  # TODO: `partial`: PO = Partially Received, SO = Partially Fulfilled
  #       `partial` は, 納品スケジュール表が必要
  #
  # PO: `in_transit` は、未着品 (arrival 前の支払い) の意味で使う. 仕入れを計上する.
  # PO:
  #   ●TODO: 未着品計上し、商品受領したときに差異があった場合どうするか?
  STATES = %w(draft confirmed in_transit delivered void).freeze
  enum :state, STATES.map{|x| [x,x]}.to_h
  

  ########################################
  # Relationships

  has_many :details, -> {order('id ASC')},
           class_name: "OrderDetail", dependent: :destroy

  #belongs_to :project, optional: true
  
  has_many :ledgers, foreign_key: :account_id, class_name: 'AccountLedger'
  
  has_many :inventories #, foreign_key: :account_id

  # Attachments
  has_many :attachments, -> { order('attachments.position') }, dependent: :destroy

  
  ########################################
  # Validations
  
  validates_presence_of :date
  
  validate  :valid_currency_change, on: :update
  validate  :greater_or_equal_ship_date

  
  # include not-yet-confirmed records
  # @param ops [Array of String]   ex. ['exp_in', 'pur_tran']
  # @return [Hash{item_id => qty}]
  def qty_delivered ops, invt
    raise ArgumentError if !ops.is_a?(Array) || ops.empty? || !ops.first.is_a?(String)
    raise TypeError if !invt.is_a?(Inventory)
    
    ods = OrderDetail.select("order_details.id, order_details.item_id, order_details.quantity, SUM(inventory_details.quantity) AS qty_delivered")
            .joins("LEFT JOIN inventories ON order_details.order_id = inventories.order_id")
            .joins("JOIN inventory_details ON inventories.id = inventory_details.inventory_id")
            .where("order_details.order_id = ?", self.id)
            .where("inventories.operation": ops)  # SQL `IN`
            .where("order_details.item_id = inventory_details.item_id")
            .group("order_details.id, order_details.item_id, order_details.quantity")
    ods = ods.where("inventories.id <> ?", invt.id) if invt.id.to_i > 0

    item_qty_h = {}
    ods.each do |od|
      item_qty_h[od.item_id] = od.qty_delivered
    end
    return item_qty_h
  end

  
  def display_state
    case state
    when 'draft';     "badge text-bg-warning" 
    when 'confirmed'; "badge text-bg-success"
    #when 'partial';   "badge text-bg-info"
    when 'in_transit'; "badge text-bg-info"
    when 'delivered'; "badge text-bg-primary"   # closed
    when 'void';      "badge text-bg-dark"
    else
      raise "internal error"
    end
  end
  
  
  def total_discount
    gross_total - total
  end

  def discount_percent
    total_discount / gross_total
  end


  # `save()` must be done by caller.
  # activerecord `enum` は, `confirmed?` と `confirmed!` (edが付く) を生やす
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

=begin "partial" not supported  
  # PO: 購買入庫から呼び出される
  def update_state!
    qty_received = 0
    ttl_balance = 0 # qty
    details.each do |det|
      qty_received += (det.quantity - det.balance)
      ttl_balance += det.balance >= 0 ? det.balance : 0 # 過剰はそのまま, 未受領だけ加算
    end

    if ttl_balance == 0
      self.state = 'delivered'
    elsif qty_received > 0
      self.state = 'partial'
    end
    
    save!
  end
=end

  
  def null!
    if can_null?
      update(state: 'nulled', nuller_id: UserSession.id, nuller_datetime: Time.zone.now)
    end
  end

  
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


   def valid_currency_change
     errors.add(:currency, I18n.t('errors.messages.movement.currency_change'))  if currency_changed? && ledgers.any?
   end

   
  # for validate()
  def greater_or_equal_ship_date
    if date && ship_date && !(date <= ship_date)
      errors.add(:ship_date, "must be >= order_date" )
    end

    if ship_date && delivery_date && !(ship_date <= delivery_date)
      errors.add(:delivery_date, "must be >= ship_date" )
    end
  end
  
end
