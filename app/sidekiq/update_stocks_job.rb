
=begin
TODO: いちいち全部を更新するのは、重いし、無駄
      1) `Inventory` の承認のときに、その品目だけ更新したほうがいい
      -> 前日以前の update 場合は、その品目だけ今日まで更新
      2) For items that have not had a transaction, it carries forward the balance
=end

# `Inventory` からその日の終わり時点での在庫を計算する
class UpdateStocksJob
  include Sidekiq::Job

  def perform(org_id)
    org = Organisation.find org_id
    change_tenant!!
    
    # date => Hash{[item, store, stock_type] => qty}
    stocks = []
    stocks[0] = Stock.where(date: org.last_stock_fixed_date)
                     .to_h {|r| [[r.item_id, r.store_id, r.invt_type], r.quantity]}
    ((org.last_stock_fixed_date + 1)..Date.today).each_with_index do |date, i|
      # First, copy all
      stock[i + 1] = stock[i].dup
      
      # And, change
      Inventory.where(date: date, state: 'confirmed').each do |invt|
        case invt.operation
        when 'exp_in'  # 購買入庫
          change stock[i + 1], invt.store_id, 1, invt.details, +1

        when 'pur_tran' # purchase-in-transit
          change stock[i + 1], invt.store_id, 10, invt.details, +1
          
        when 'pit_in' # PIT -> IN
          # 数量変更があったときに不味い. 元の `Inventory` を呼び出して、それをマイナスする
          orig = Inventory.eager_load(:details)
                    .where(order_id: invt.order_id, operation:'pur_tran').take
          change stock[i + 1], orig.store_id, 10, orig.details, -1
          change stock[i + 1], invt.store_id, 1, invt.details, +1
          
        when 'exp_out' # 仕入戻し
          change stock[i + 1], invt.store_id, 1, invt.details, -1

        when 'inc_out'  # 販売出庫 w/ order
          change stock[i + 1], invt.store_id, 1, invt.details, -1

        when 'inc_in'   # 顧客返品
          change stock[i + 1], invt.store_id, 1, invt.details, +1

        when 'out'     # 転送出庫
          change stock[i + 1], invt.store_id, 1, invt.details, -1
          change stock[i + 1], invt.order.trans_to_id, 5, invt.details, +1
          
        when 'in'      # 転送入庫
          change stock[i + 1], invt.order.store_id, 5, invt.details, -1
          change stock[i + 1], invt.store_id, 1, invt.details, +1
          
        when 'trans'   # 1-step transfer
          raise "not implemented"
        else
          raise "internal error"
        end
      end
    end
  end

  
private
  
  def change stock, store_id, stock_type, details, weight
    details.each do |det|
      stock[det.item_id, store_id, stock_type] = 
            (stock[det.item_id, store_id, stock_type] || 0) + det.quantity * weight
    end
  end

end
