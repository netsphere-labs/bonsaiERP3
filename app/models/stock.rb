
# author: Boris Barroso
# email: boriscyber@gmail.com

# on-hand stock: total number of items in a warehouse. inventory physically available
# available stock: on-hand stock minus any quantities reserved for open
#                  transaction, such as sales orders, stock transfer etc.
class Stock < ApplicationRecord
  belongs_to :store
  belongs_to :item

  INVT_TYPES = {
    1 => "Unrestricted-Use Stock",                 # from 101
    #3 => "Returns",    販売の在庫引当や、仕入戻しは、在庫の状態ではない
    5 => "Stock in transfer (store to store)",     # transfer from 303, out 305
    10 => "Valuated Goods Receipt Blocked Stock",  # from 107, out 109
    "
  #validations

  validates_presence_of :date
  validates_numericality_of :minimum, greater_than_or_equal_to: 0 #, allow_nil:  true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :store_house, -> (store_id) { where(store_id: store_id) }
  scope :mins, -> { where("stocks.quantity < stocks.minimum") }
  scope :item_like, -> (s) { active.joins(:item).where("items.name ILIKE :s OR items.code ILIKE :s", s: "%#{s}%") }
  scope :available_items, -> (store_id, s) { item_like(s).where("store_id=? AND quantity > 0", store_id) }

  delegate :name, :price, :code, :to_s, :type, :unit_symbol, to: :item, prefix: true

  # Sets the minimun for an Stock
  def self.new_minimum(item_id, store_id)
    Stock.find_by(item_id: item_id, store_id: store_id)
  end

  def self.minimum_list
    Stock.select("COUNT(item_id) AS items_count, store_id").where("quantity <= minimum").group(:store_id).count
  end

  # Creates a new instance with an item
  def save_minimum(min)
    min = min.is_a?(Numeric) ? min.to_d : min.to_s.to_d
    if min < 0
      self.errors[:minimum] << I18n.t("errors.messages.greater_than", count: 0)
      false
    else
      self.minimum = min
      self.user_id = UserSession.id
      self.save
    end
  end
end
