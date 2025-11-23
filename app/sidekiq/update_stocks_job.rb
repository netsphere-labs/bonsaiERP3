
=begin
いちいち全部を更新するのは、重いし、無駄
  1) `Inventory` の承認のときに、その品目だけ更新する. See Stock.change()
      -> 前日以前の update 場合は、その品目だけ今日まで更新
  2) For items that have not had a transaction, it carries forward the balance
=end

# - Move the `stock_fixed_date` forward
# - Create the opening balance for the next day.
class UpdateStocksJob
  include Sidekiq::Job

  def perform(*args)
    Organisation.all.each do |org|  # `org` is always in `public` schema.
      Time.zone = org.time_zone
      today = Time.zone.today
      break if today <= org.stock_fixed_date + 1

if USE_SUBDOMAIN
      Apartment::Tenant.switch!(org.tenant)
end
      ActiveRecord::Base.transaction do
        ((org.stock_fixed_date + 1)..(today - 1)).each do |date|
          # 残高復活がある。毎日の分を読み直す
          qtys = Stock.find_by_sql [<<EOS, date]
SELECT S1.*, S2.quantity AS next_qty FROM stocks S1
  LEFT JOIN stocks S2 ON S1.date + 1 = S2.date AND
            S1.item_id = S2.item_id AND S1.store_id = S2.store_id AND
            S1.invt_type = S2.invt_type
  WHERE S1.date = ?
EOS
          # タイミングの問題で, 先に Stock.change() で更新されていた場合, 何も
          # しない
          qtys.each do |qty|
            # opening balance. 残高 0 の "次の" レコードは不要
            if !qty.next_qty && qty.quantity != 0
              stk = Stock.create!(date: date + 1,  # 最後, today になる
                                  item_id: qty.item_id,
                                  store_id: qty.store_id,
                                  invt_type: qty.invt_type,
                                  quantity: qty.quantity)
            end
          end
        end # of each date
        
        org.stock_fixed_date = today - 1
        org.save!
      end # transaction
    end # each org
  end

end
