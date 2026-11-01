
# author: Boris Barroso
# email: boriscyber@gmail.com

# 個々の伝票にぶら下がる, アイテムの変動
class InventoryDetail < ApplicationRecord
  # 親. 入出庫伝票. store_id は親で持つ
  belongs_to :inventory
  
  belongs_to :item
  
  # この validation は、update() で誤って重複判定になってしまう
  #validates :item_id, presence: true, uniqueness: { scope: :inventory_id }
  
  # 預託品の場合は, 預託品倉庫への転送扱い
  #belongs_to :store

  #validates_presence_of :movement_type

  # 入庫 = 0 以上, 出庫 = マイナス
  validates_presence_of :quantity
  validates_numericality_of :quantity, greater_than: 0

  validates_presence_of :txn_funct_amount, if: -> { !txn_amount.nil? }
  
  # for form (dummy)
  attribute :txn_price, :decimal 

  attr_accessor :available

  # nominal
  def unit_price
    return nil if !txn_amount
    return (BigDecimal(txn_amount) / quantity).round(2)
  end
end
