
# 品目元帳. 単数形リソース
class MaterialLedgerController < ApplicationController
  # GET
  def show
    if params[:mat_ledger_search].blank?
      @search = MatLedgerSearch.new
    else
      @search = MatLedgerSearch.new(params.require(:mat_ledger_search)
                                      .permit(*MatLedgerSearch.attribute_names))
      # Array of InventoryDetail
      @pagy, @ledgers = pagy(:offset, @search.search()
            .order('inventories.date, inventories.id, inventory_details.id'))
    end
  end
end
