
# 品目元帳. 単数形リソース
class MaterialLedgerController < ApplicationController
  def show
    @search = nil
    @ledgers = Inventory.all
  end
end
