
# author: Boris Barroso
# email: boriscyber@gmail.com

# フォームオブジェクト for GoodsReceiptPo
class Expenses::InventoryIn < Inventories::Form
  
  # @param detail_params  [Hash{lineno => Hash}] params
  #   {"1"=>{"item_id"=>"1", "quantity"=>"567"},
  #    "2"=>{"item_id"=>"1", "quantity"=>"0.0"},
  def self.create_details_from_params detail_params, store_id
    ary = []
    detail_params.each do |_lineno, h|
      m = InventoryDetail.new h.permit(:item_id, :price, :quantity, :line_total)
      m.movement_type = 101  # supplier -> unrestricted stock
      m.store_id = store_id
      if m.quantity != 0.0
        m.price = m.line_total / m.quantity if !h[:line_total].blank?
        ary << m
      end
    end

    return ary
  end
  
  
  def build_details_from_order
    # The `balance` is the number of items that are not yet received.
    order.details.each do |det|
      # The quantity should be entered manually.
      self.details << InventoryDetail.new(item_id: det.item_id,
                                          price: det.price, quantity: 0)
    end
  end


=begin
    res = true

    save do
      update_expense_details
      update_expense_balanace
      expense.operation_type = 'inventory_in'

      expense_errors.set_errors
      res = expense.save
      res = res && update_stocks
      Inventories::Errors.new(@inventory, stocks).set_errors
      @inventory.account_id = @expense.id
      @inventory.contact_id = @expense.contact_id
      res && @inventory.save
    end
=end

  #def movement_detail(item_id)
  #  @expense.details.find {|det| det.item_id === item_id }
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

    def valid_items_ids
      details.all? {|v| expense_item_ids.include?(v.item_id) }
    end

    def update_expense_details
      details.each do |det|
        det_exp = movement_detail(det.item_id)
        det_exp.balance -= det.quantity
      end
    end

    def update_expense_balanace
      @expense.balance_inventory = balance_inventory
      @expense.delivered = inventory_left === 0
    end

    def expense_calculations
      @expense_calculations ||= Movements::DetailsCalculations.new(@expense)
    end

    def expense_item_ids
      @expense_item_ids ||= @expense.details.map(&:item_id)
    end

    def expense_errors
      @expense_errors ||= Expenses::Errors.new(expense)
    end
end
