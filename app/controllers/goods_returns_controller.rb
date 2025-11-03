
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫からの return to supplier.
# Goods Return Request (order) は `GoodsReturnRequestsController`
class GoodsReturnsController < ApplicationController
  before_action :set_store
  
  #before_action :set_store_and_expense

  def index
    @orders = GoodsReturnRequest.where(state:['confirmed', 'partial'],
                                       store_id: @store.id)
  end

  
  # GET
  # /expenses_inventory_ins/new?store_id=:store_id&expense_id=:expense_id
  def new
    @inv = Expenses::InventoryOut.new(
      store_id: @store.id, expense_id: @expense.id, date: Date.today,
      description: "Devolución mercadería egreso #{ @expense }"
    )
    @inv.build_details
  end

  # POST /expenses_inventory_ins
  # store_id&expense_id=:expense_id
  def create
    @inv = Expenses::InventoryOut.new({store_id: @store.id, expense_id: @expense.id}.merge(inventory_params))

    if @inv.create
      redirect_to expense_path(@expense.id), notice: 'Se realizó la devolución de inventario.'
    else
      render :new
    end
  end

  
private

  def set_store
    @store = Store.find params[:store_id]
  end
  
    def set_store_and_expense
      @expense = Expense.active.find(params[:expense_id])
      @store = Store.active.find(params[:store_id])
    rescue
      redirect_to expenses_path, alert: 'Ha seleccionado un almacen o un egreso invalido.' and return
    end

    def inventory_params
      params.require(:expenses_inventory_out).permit(
        :description, :date, :store_id, :expense_id,
        inventory_details_attributes: [:item_id, :quantity]
      )
    end
end
