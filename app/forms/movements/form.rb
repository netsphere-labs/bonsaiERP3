
# author: Boris Barroso
# email: boriscyber@gmail.com

=begin
contact_id が必須の 4 種類

1. PurchaseOrder

2. コントローラ `GoodsReturnRequestsController`, model = `GoodsReturnRequest`
   form object = `Expenses::Devolution`

3. SalesOrder

4. controller = `DevolutionsController`, model = `CustomerReturnRequest`
   form object = `Incomes::Devolution`

# "条件付買取仕入" は, 販売期間終了後に, 返品することができる取引形態
# 百貨店での, 季節商品やファッション商品で見られる
# 百貨店には、保管責任はあるが、在庫リスクはない。
# See https://www.s-terada.com/%E5%AE%9F%E5%8B%99%E8%AB%96%E6%96%87/%E7%99%BE%E8%B2%A8%E5%BA%97%E7%B4%8D%E5%85%A5%E6%A5%AD%E8%80%85%E3%81%AE%E4%BC%9A%E8%A8%88%E3%81%A8%E7%A8%8E%E5%8B%99-%E6%B6%88%E5%8C%96%E4%BB%95%E5%85%A5%E3%81%A8%E3%83%9E%E3%83%8D%E3%82%AD%E3%83%B3/
=end


class Movements::Form < BaseForm
  # SalesOrder or PurchaseOrder
  attr_reader :model_obj

  # Array of MovementDetail
  attr_reader :details
  
  # form fields
  delegate :date, :contact_id, :currency, :ship_date, :draft?, #:description, :tax_id,
           to: :model_obj

  # PO only
  delegate :store_id, :delivery_loc, :incoterms, :delivery_date, :contact,
           to: :model_obj, allow_nil:true

  # Transfer Request Only
  delegate :trans_to_id, to: :model_obj, allow_nil:true
  
  # for field required star
  validates_presence_of :date
  validates_presence_of :ship_date
  
  validate :validate_models

  
  def initialize order
    raise TypeError if !order.is_a?(Order) 
    super()
    @model_obj = order
    @details = order.details
  end

  
  # @param model_params   permitted params for model object
  # @param detail_params for nested array              
  def assign model_params, detail_params
    model_obj.assign_attributes model_params #.permit(.....)
    @details = Movements::Form.create_details_from_params(detail_params)
  end

  # ActiveModel::Validations  -> DON'T override `valid?` directly.
  #def valid?
  #     1. errors.clear
  #     2. run_validations!
  #     3. return errors.empty?
  #end

  # nest している場合, 結局, 保存と #valid? を同時に行わないと動かない
  # トランザクションは呼び出し側で行うこと
  def save!
    if !model_obj.valid?
      # promote errors
      errors.merge!(model_obj.errors)
      # new: record that has `errors` 
      raise ActiveRecord::RecordInvalid.new(self)
    end
    model_obj.save!
    
    details.each do |detail|
      detail.order_id = model_obj.id  
      #detail.balance = detail.quantity  # set in MovementDetail. only on create
    end
    if !self.valid?
      raise ActiveRecord::RecordInvalid.new(self)
    end
    details.each do |detail| detail.save! end
  end

  
private

  # for `validate()`. 親側の validation は `save!` のなかで実行する.
  def validate_models
    if details.empty?
      errors.add(:details, "need at_least_one_item")
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

  
  # @param detail_params [Hash{lineno => Hash}] params
  #   {"1"=>{"item_id"=>"1", "price"=>"123", "quantity"=>"567", "description"=>"aaaa"},
  #    "2"=>{"item_id"=>"1", "price"=>"0.0", "quantity"=>"0.0", "description"=>""},
  def self.create_details_from_params(detail_params)
    #raise detail_params.inspect # DEBUG

    ary = []
    detail_params.each do |_lineno, h|
      m = MovementDetail.new h.permit(:item_id, :price, :quantity, :description)
      (ary << m) if m.quantity != 0.0
    end

    return ary
  end

end
