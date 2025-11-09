
# author: Boris Barroso
# email: boriscyber@gmail.com

# form object for transfer-in-2-steps - in
class Inventories::In < Inventories::Form

  # @param detail_params  [Hash{lineno => Hash}] params
  #   {"1"=>{"item_id"=>"1", "quantity"=>"567"},
  #    "2"=>{"item_id"=>"1", "quantity"=>"0.0"},
  def self.create_details_from_params detail_params, store_id
    ary = []
    detail_params.each do |_lineno, h|
      m = InventoryDetail.new h.permit(:item_id, :quantity)  # `price` がない
      m.movement_type = 305 # transfer in two steps – putaway  ここが異なる
      m.store_id = store_id
      (ary << m) if m.quantity != 0.0
    end

    return ary
  end


  # TODO: 出庫の場合は, 現在庫の表示も必要
  def build_details_from_order
    order.details.each do |det|
      # `balance` そのままではなく, 手入力する
      self.details << InventoryDetail.new(item_id: det.item_id, quantity: 0)
    end
  end
  
=begin
  def create
    res = true
    save do
      res = update_stocks
      Inventories::Errors.new(inventory, stocks).set_errors
      res && inventory.save
    end
  end
=end
  
  #def details_form_name
  #  'inventories_out[inventory_details_attributes]'
  #end

private

    #def operation
    #  'out'
    #end

    def update_stocks
      res = true
      new_stocks = []
      stocks.each do |st|
        stoc = Stock.new(store_id: store_id, item_id: st.item_id,
                         quantity: stock_quantity(st), minimum: st.minimum)

        res = stoc.save && st.update_attribute(:active, false)
        new_stocks << stoc

        return false unless res
      end

      klass_details.stocks = new_stocks

      res
    end

    def stock_quantity(st)
      st.quantity - item_quantity(st.item_id)
    end
end

