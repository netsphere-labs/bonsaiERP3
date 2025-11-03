
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での顧客返品の受取り. Devolutions of inventory for Income
# Customer Return Request (order) は `DevolutionsController`
class CustomerReturnsController < ApplicationController
  before_action :set_store

  before_action :set_inv,
                only: %i[show edit update destroy confirm void]


  def index
    @orders = CustomerReturnRequest.where(store_id: @store.id)
    @invs = Inventory.where(operation:'inc_in').page(params[:page])
  end

  def show
  end

  
  # GET
  # /incomes_inventory_ins/new?store_id=:store_id&income_id=:income_id
  def new
    @inv = Incomes::InventoryIn.new(
      store_id: @store.id, income_id: @income.id, date: Time.zone.now.to_date,
      description: "Devolución mercadería ingreso #{ @income }"
    )
    @inv.build_details
  end

  # POST /incomes_inventory_ins
  # store_id&income_id=:income_id
  def create
    @inv = Incomes::InventoryIn.new({store_id: @store.id, income_id: @income.id}.merge(inventory_params))

    if @inv.create
      redirect_to income_path(@income.id), notice: "Se realizó la devolución de inventario."
    else
      render :new
    end
  end


  def edit
  end

  def update
  end


  def destroy
  end

  def confirm
  end

  def void
  end

  
private

  def set_store
    @store = Store.find params[:store_id]
  end

  def set_inv
    @inv = Inventory.where(operation: 'inc_in', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@inv
  end
    
=begin
    def set_store_and_income
      @income = Income.active.find(params[:income_id])
      @store = Store.active.find(params[:store_id])
    rescue
      redirect_to incomes_path, alert: 'Ha seleccionado un almacen o un ingreso invalido.' and return
    end
=end

    def inventory_params
      params.require(:incomes_inventory_in).permit(
        :description, :date, :store_id, :income_id,
        inventory_details_attributes: [:item_id, :quantity]
      )
    end
end
