
=begin
TODO: いちいち全部を更新するのは、重いし、無駄
      1) <s>`Inventory` の承認のときに、その品目だけ更新したほうがいい</s> fixed.
      -> 前日以前の update 場合は、その品目だけ今日まで更新
      2) For items that have not had a transaction, it carries forward the balance
=end

# - <s>`Inventory` から today の終わり時点での在庫を計算する</s> no need
# - Move the `stock_fixed_date` forward
# - Create the opening balance for the next day.
class UpdateStocksJob
  include Sidekiq::Job

  def perform(*args)
    Organisation.all.each do |org|  # `org` is in `public`
      Time.zone = org.time_zone
      today = Time.zone.today
      break if today <= org.stock_fixed_date + 1

if USE_SUBDOMAIN
      Apartment::Tenant.switch!(org.tenant)
end
      ActiveRecord::Base.transaction do
        (org.stock_fixed_date..(today - 2)).each do |date|
          # All!
          qtys = Stock.where(date: date)
                      .to_h {|r| [[r.item_id, r.store_id, r.invt_type], r.quantity]}

          qtys.each do |dim, qty|
            stk = Stock.where(date: date + 1,
                            item_id: dim[0], store_id: dim[1], invt_type: dim[2])
                     .take
            if !stk && qty != 0
              # opening balance
              stk = Stock.create!(date: date + 1, item_id: dim[0],
                                  store_id: dim[1], invt_type: dim[2],
                                  quantity: qty)
            end
          end
        end
        
        org.stock_fixed_date = today - 1
        org.save!
      end # transaction
    end # org
  end

end
