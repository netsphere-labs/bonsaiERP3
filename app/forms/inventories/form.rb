
# author: Boris Barroso
# email: boriscyber@gmail.com

# "form object for 倉庫からの入出庫" の基底クラス
class Inventories::Form < BaseForm
  # `Inventory` 入出庫伝票
  attr_reader :model_obj

  # Array of InventoryDetail
  attr_reader :details

  delegate :date, :store_id, :description, to: :model_obj
  
  # `belongs_to()` が使えない
  def store
    @store ||= Store.active.where(id: store_id).take
  end
  
  delegate :ref_number, :project_id, :order_id, :account_id,
           to: :model_obj, allow_nil: true

  # `belongs_to()` が使えない
  def order
    if order_id
      @order ||= Order.find order_id
    end
    return @order
  end
  
  #delegate :stocks, :stock, :stocks_to, :detail, :item_ids, :item_quantity,
  #         to: :klass_details

  # field required red star
  validates_presence_of :date

  validate :validate_details

  
  def initialize model
    raise TypeError if !model.is_a?(Inventory)
    super() # set @attributes
    @model_obj = model
    @details = model.details
  end

  def assign model_params, detail_params, store_id
    model_obj.assign_attributes model_params
    @details = self.class.create_details_from_params(detail_params, store_id)
  end


  # トランザクションは呼出し側で掛けること
  def save!
    if !model_obj.valid?
      # promote errors
      errors.merge!(model_obj.errors)
      raise ActiveRecord::RecordInvalid.new(self)
    end
    model_obj.save!
    
    details.each do |detail|
      detail.inventory_id = model_obj.id
    end
    if !self.valid?   # フォームオブジェクトの validation. details 存在する
      raise ActiveRecord::RecordInvalid.new(self)
    end
    
    details.each do |detail| detail.save! end
  end

  
private

  # for `validate()`. 親側の validation は `save!` のなかで実行する.
  def validate_details
    if details.empty?
      errors.add(:details, I18n.t("errors.messages.inventory.at_least_one_item"))
      return
    end
    
    # run validations for all nested objects
    err_count = details.count {|detail|
      # only useful when `:autosave` option is enabled.
      next if detail.respond_to?(:marked_for_destruction?) && detail.marked_for_destruction?
      !detail.valid?
    }
    if err_count > 0
      errors.add :details, "Some error(s) in details"
    end

    errors.add :details, "Item not unique" if !UniqueItem.new(self).valid?
  end

=begin
  def inventory
    @inventory ||= begin
      i = Inventory.new(
        store_id: store_id, date: date, description: description,
        inventory_details_attributes: get_inventory_details,
        operation: operation
      )
      i.set_ref_number
      i
    end
  end
=end
  
  def details_serialized
    details.map do |v|
      v.attributes.merge(stock_with_items(v.item_id).attributes)
    end
  end


private

    def stock_with_items(item_id)
      stock_items_hash.fetch(item_id) { StockWithItem.new }
    end

    def stock_items_hash
      @stock_items_hash ||= begin
         res =  store.stocks.includes(:item).where(item_id: details.map(&:item_id))
         Hash[ res.map { |v| [v.item_id, StockWithItem.new(v)] }]
      end
    end

=begin
    # Saves and in case there are errors in inventory these are set on
    # the Iventories::Form instance
    def save(&b)
      res = valid? && @inventory.valid?
      res = commit_or_rollback { b.call } if res

      set_errors(@inventory) unless res

      res
    end
=end
  
    def get_inventory_details
      if inventory_details_attributes.nil?
        []
      else
        inventory_details_attributes
      end
    end

    def klass_details
      @klass_details ||= Inventories::Details.new(@inventory)
    end

#    def self.public_attributes
#      [:store_id, :date, :description]
#    end


  #def unique_item_ids
  #self.errors.add(:base, I18n.t("errors.messages.item.repeated_items")) unless UniqueItem.new(@inventory).valid?
  #end

end


class StockWithItem
  attr_accessor :unit, :item, :stock

  def initialize(obj = nil)
    @item = obj.item_to_s
    @unit = obj.item_unit_symbol
    @stock = obj.quantity
  rescue
    @stock = BigDecimal.new(0)
  end

  def attributes
    { item: item, unit: unit, stock: stock }
  end
end
