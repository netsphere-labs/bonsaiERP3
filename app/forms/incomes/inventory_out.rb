
# author: Boris Barroso
# email: boriscyber@gmail.com

# フォームオブジェクト for 倉庫からの出荷/納入
class Incomes::InventoryOut < Inventories::Form

  #validate :valid_quantities
  #validate :valid_item_ids

  #delegate :income_details, to: :income
  #delegate :balance_inventory, :inventory_left, to: :income_calculations


  # @param detail_params  [Hash{lineno => Hash}] params
  #   {"1"=>{"item_id"=>"1", "quantity"=>"567"},
  #    "2"=>{"item_id"=>"1", "quantity"=>"0.0"},
  def self.create_details_from_params detail_params, store_id
    ary = []
    detail_params.each do |_lineno, h|
      m = InventoryDetail.new h.permit(:item_id, :price, :quantity)
      m.movement_type = 261  # Goods issue for an order. ここが異なるので別に定義
      m.store_id = store_id
      (ary << m) if m.quantity != 0.0
    end

    return ary
  end


  # TODO: 出庫の場合は, 現在庫の表示も必要
  def build_details_from_order
    order.details.each do |det|
      # `balance` そのままではなく, 手入力する
      self.details << InventoryDetail.new(item_id: det.item_id ,
                                          price: det.price, quantity: 0)
    end
  end


=begin
    save do
      update_income_details
      update_income_balanace
      income.operation_type = 'inventory_out'

      income_errors.set_errors
      res = income.save
      res = res && update_stocks
      Inventories::Errors.new(@inventory, stocks).set_errors
      @inventory.account_id = @income.id
      @inventory.contact_id = @income.contact_id
      res && @inventory.save
    end
  end
=end
  
  #def movement_detail(item_id)
  #  @income.details.find {|det| det.item_id === item_id }
  #end

  
private

  def valid_quantities
    res = true
    details.each do |det|
      if det.quantity > movement_detail(det.item_id).balance
        det.errors.add(:quantity, I18n.t('errors.messages.inventory.movement_quantity'))
        res = false
      end
    end

    self.errors.add(:base, I18n.t('errors.messages.inventory.item_balance')) unless res
  end

  def valid_item_ids
    unless details.all? {|v| income_item_ids.include?(v.item_id) }
      self.errors.add(:base, I18n.t("errors.messages.inventory.movement_items"))
    end
  end

  def update_income_details
    details.each do |det|
      det_exp = movement_detail(det.item_id)
      det_exp.balance -= det.quantity
    end
  end

  def update_income_balanace
    @income.balance_inventory = balance_inventory
    @income.delivered = inventory_left === 0
  end

  def income_calculations
    @income_calculations ||= Movements::DetailsCalculations.new(@income)
  end

  def income_item_ids
    @income_item_ids ||= @income.details.map(&:item_id)
  end

  def income_errors
    @income_errors ||= Incomes::Errors.new(income)
  end
end
