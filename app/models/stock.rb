
# author: Boris Barroso
# email: boriscyber@gmail.com

# on-hand stock: total number of items in a warehouse. inventory physically
#                available
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
  }
  
  # validations ###############################################

  validates_presence_of :date

  validates_presence_of :invt_type
  validates_inclusion_of :invt_type, in: INVT_TYPES.keys

  validates_presence_of :quantity
  validates_presence_of :unitary_cost
  
  validates_numericality_of :minimum, greater_than_or_equal_to: 0 #, allow_nil:  true

  # Scopes

  scope :store_house, -> (store_id) { where(store_id: store_id) }
  scope :mins, -> { where("stocks.quantity < stocks.minimum") }
  scope :item_like, -> (s) { active.joins(:item).where("items.name ILIKE :s OR items.code ILIKE :s", s: "%#{s}%") }
  scope :available_items, -> (store_id, s) { item_like(s).where("store_id=? AND quantity > 0", store_id) }

  #delegate :name, :price, :code, :to_s, :type, :unit_symbol, to: :item, prefix: true

  
  #######################################################################
  # Class Methods
  
  # Sets the minimun for an Stock
  def self.new_minimum(item_id, store_id)
    Stock.find_by(item_id: item_id, store_id: store_id)
  end

  def self.minimum_list
    Stock.select("COUNT(item_id) AS items_count, store_id").where("quantity <= minimum").group(:store_id).count
  end

  
  # 24 時間営業の場合、夜間バッチで残高繰越はできない。昨日まで残高があり、今日
  # のレコードがないときの考慮が必要。
  # このメソッド内で確実に伸ばす
  #
  # The caller must initiate a transaction
  def self.change apply_date, store_id, stock_type, detail_ary, weight
    raise TypeError if !apply_date.is_a?(Date)

    item_ary = detail_ary.map {|x| x.item_id}
    
    # まず apply_date 当日を更新する.
    # 過去データの更新の場合, apply_date の翌日以降のデータが存在する。順次伸ば
    # す.
    # nil との max はエラーになる
    max_date = Stock.where(store_id: store_id, invt_type: stock_type,
                           item_id: item_ary)
                    .order('date DESC').limit(1).take &.date
    max_date = max_date ? [max_date, apply_date].max : apply_date

    (apply_date ..max_date).each do |date|
      stock = Stock.where(date: date, store_id: store_id, invt_type: stock_type,
                          item_id: item_ary)
                   .to_h {|r| [r.item_id, r]}
      detail_ary.each do |det|
        # ナルの場合, 直近の日付の残高を引き継ぐ
        prev = Stock.where('date <= ? AND store_id = ? AND invt_type = ? AND item_id = ?',
                           date - 1, store_id, stock_type, det.item_id)
                    .order('date DESC').limit(1).take
        stock[det.item_id] ||=
            Stock.new(date: date, store_id: store_id, invt_type: stock_type,
                      item_id: det.item_id,
                      quantity: (prev ? prev.quantity : 0),
                      unitary_cost: (prev ? prev.unitary_cost : 0) )
        stock[det.item_id].quantity += det.quantity * weight
        stock[det.item_id].save!
      end
    end
  end


  def self.get_balance(date, store_id, stock_type, item_id)
    r = Stock.where('date <= ? AND store_id = ? AND invt_type = ? AND item_id = ?',
                    date, store_id, stock_type, item_id)
             .order('date DESC').limit(1).take
    return !r ? 0 : r.quantity
  end

  
  #######################################################################
  # Instance Methods
  
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
