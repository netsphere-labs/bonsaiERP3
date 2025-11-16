
# `Inventory` からその日の終わり時点での在庫を計算する
class UpdateStocksJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
  end
end
