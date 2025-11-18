
# `Inventory` からその日の終わり時点での在庫を計算する
class UpdateStocksJob
  include Sidekiq::Job

  def perform(*args)
    # date => Hash{[item, store, stock_type] => qty}
    stocks = []
    stocks[0] = Stock.where(date: last_fixed_date)
                     .to_h {|r| [[r.item_id, r.store_id, r.invt_type], r.quantity]}
    ((last_fixed_date + 1)..Date.today).each_with_index do |date, i|
      # First, all copy                                               
      stock[i + 1] = stock[i].dup
      
      # And, change
      Inventory.where(date: date, state: 'confirmed').each do |invt|
        case invt.operation
        when 'exp_in'  # 購買入庫
          change stock[i + 1], invt.store_id, 1, invt.details, +1

        when 'pur_tran' # purchase-in-transit
          change stock[i + 1], invt.store_id, 10, invt.details, +1
          
        when 'pit_in' # PIT -> IN
          change stock[i + 1], invt.store_id, 10, invt.details, -1
          change stock[i + 1], invt.store_id, 1, invt.details, +1
          
        when 'exp_out' # 仕入戻し
          change stock[i + 1], invt.store_id, 1, invt.details, -1

        when 'inc_out'  # 販売出庫
          change stock[i + 1], invt.store_id, 1, invt.details, -1

        when 'inc_in'   # 顧客返品
          change stock[i + 1], invt.store_id, 1, invt.details, +1

        when 'in'      # 転送入庫
          change stock[i + 1], invt.store_id, 1, invt.details, +1
          
        when 'out'     # 転送出庫
        when 'trans'   # 1-step transfer
        else
          raise "internal error"
        end
      end
    end
  end

private
  def change stock, store_id, stock_type, details, weight
    details.each do |det|
      stock[det.item_id, store_id, stock_type] ||= 0
      stock[det.item_id, store_id, stock_type] += det.quantity * weight
    end
  end

end
