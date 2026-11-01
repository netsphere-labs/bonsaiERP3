
# author: Boris Barroso
# email: boriscyber@gmail.com

# フォームオブジェクト for Goods Receipt PO
class Movements::ExpenseIn < Inventories::Form

  # Called from `Inventories::Form#assign()`
  #
  # @param detail_params  [Hash{lineno => Hash}] params
  #   {"1"=>{"item_id"=>"1", "quantity"=>"567"},
  #    "2"=>{"item_id"=>"1", "quantity"=>"0.0"},
  def self.create_details_from_params model_obj, detail_params, store_id, org
    raise TypeError if !model_obj.is_a?(Inventory)
    raise ArgumentError if !(store_id.to_i > 0)
    raise TypeError if !org.is_a?(Organisation)
    
    ary = []
    funct_curr = Money::Currency.find(org.currency)
    
    detail_params.each do |_lineno, h|
      m = InventoryDetail.new(
            h.permit(:item_id, :txn_price, :quantity, :txn_amount) )
      #m.movement_type = case model_obj.operation
      #                  when 'exp_in';   101  # supplier -> unrestricted stock
      #                  when 'pur_tran'; 107  # supplier -> valued blocked stock
      #                  when 'pit_in'; 109 # blocked stock -> unrestricted stock
      #                  else
      #                    raise "internal error"
      #                  end
      #m.store_id = store_id
      if m.quantity && m.quantity != 0.0
        m.txn_amount = if h[:txn_amount].blank?
                         nominal_amount((m.txn_price || 0.0) * m.quantity,
                                        model_obj.curr_code)
                       else
                         nominal_amount(m.txn_amount, model_obj.curr_code)
                       end
        m.txn_funct_amount = CurrXchg.convert(
                        Money.from_cents(m.txn_amount, model_obj.curr_code),
                        funct_curr,
                        model_obj.date)
        ary << m
      end
    end

    return ary
  end
  
  
  def build_details_from_order
    # The `balance` is the number of items that are not yet received.
    order.details.each do |det|
      self.details << InventoryDetail.new(item_id: det.item_id,
                                          txn_price: det.edit_price,
                                          quantity: det.balance)
    end
  end

  
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
