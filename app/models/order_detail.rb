
# author: Boris Barroso
# email: boriscyber@gmail.com

# order 内の明細行
class OrderDetail < ApplicationRecord
  # 親
  belongs_to :order

  # どちらか一方
  belongs_to :item, optional:true
  belongs_to :account, optional:true
  
  # Validations
  validate :check

  # when excessive delivered, qty = 0, balance < 0
  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  before_create :set_balance_on_create
  
  #validate :change_of_item_id, unless: :new_record?
  #validate :quantity_eq_balance, if: :marked_for_destruction?

  delegate :unit_name, :unit_symbol, to: :item, allow_nil: true

  # for form object
  attribute :edit_price, :decimal
  
  def unit_price
    # `amount` は正規化されているので、単に小数点以下2桁目までを求める
    #curr = Money::Currency.find(order.currency)
    return (BigDecimal(amount) / quantity).round(2)
  end


  def data_hash
    {
      id: id,
      item_id: item_id,
      #original_price: original_price,
      price: price,
      quantity: quantity,
      #subtotal: subtotal
    }
  end

  def valid_for_destruction?
    unless(res = quantity === balance)
      errors.add(:item_id, I18n.t('errors.messages.movement_details.not_destroy'))
      self.quantity = quantity_was
      @marked_for_destruction = false
    end
    res
  end

  
private

  # for validate()
  def check
    if !((item_id && !account_id) || (!item_id && account_id))
      errors.add :base, "must set item_id or account_id"
    end

    # balance < 0: Excessive delivered
    if quantity < balance
      errors.add :balance, I18n.t('errors.messages.movement_details.balance')
    end
  end

  # for `before_create()`
  def set_balance_on_create
    self.balance = quantity
  end

  #def quantity_eq_balance
  #self.errors.add(:quantity, "No se puede")  unless balance == quantity
  #end

=begin
  def change_of_item_id
    # *_changed? メソッドは ActiveModel::Dirty の機能
      self.errors.add(:item_id, I18n.t('errors.messages.movement_details.item_changed'))  if item_id_changed?
  end
=end
end
