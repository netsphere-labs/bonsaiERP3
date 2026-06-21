
# author: Boris Barroso
# email: boriscyber@gmail.com

# Product/Item
class Item < ApplicationRecord

  include ::Models::Tag
  #include ::Models::Updater

  # マスタの変更履歴
  #include ::Models::History
  has_many :histories, ->{order('histories.created_at DESC, id DESC')},
                       as: :historiable, dependent: :destroy
  
  ##########################################
  # Callbacks
  
  before_validation :trim_code
  #before_save :set_unit
  before_destroy :check_items_destroy

  ##########################################
  # Relationships
  
  belongs_to :unit

  # 勘定科目セット
  belongs_to :accounting, class_name: "ItemAccounting"
  
  has_many   :stocks, -> { where(active: true) }
  has_many   :income_details
  has_many   :expense_details
  has_many   :inventory_details

  belongs_to :creator,  class_name: 'User'
  
  # Attachments
  has_many :attachments, -> { order('attachments.position') }, dependent: :destroy


  ##########################################
  # Validations
  validates_presence_of   :name, :unit_id
  #validates_uniqueness_of :name

  validates_presence_of   :code
  validates_uniqueness_of :code

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :buy_price, numericality: { greater_than_or_equal_to: 0 }
  validates_lengths_from_database


  ##########################################
  # Scopes
  scope :active   , -> { where(active: true) }
  scope :income   , -> { where(active: true, for_sale: true) }
  scope :inventory, -> { where(stockable: true) }
  scope :for_sale , -> { where(for_sale: true) }
  scope :search   , ->(s) {
    where("items.name ILIKE :s OR items.code ILIKE :s", s: "%#{s}%")
  }


  # Sums the stocks of a item
  def total_stock
    stocks.reduce(0) { |sum, st| sum += st.quantity }
  end

  
private

    # checks if there are any items on destruction
    def check_items_destroy
      if MovementDetail.where(item_id: id).any? or InventoryDetail.where(item_id: id).any?
        errors.add(:base, "El item es usado en otros registros relacionados")
        false
      else
        true
      end
    end

  # For before_validation()
  def trim_code
    self.code = code.to_s.unicode_normalize(:nfkc).strip.upcase
  end

  #  def set_unit
  #    self.unit_symbol = unit.symbol
  #    self.unit_name = unit.name
  #  end
end
