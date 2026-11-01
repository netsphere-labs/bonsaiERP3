
# 単数形
class StocksController < ApplicationController
  def show
    @stocks = Stock.all
  end
end
