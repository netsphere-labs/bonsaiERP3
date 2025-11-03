
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での Inventory transfer in two-steps - in   TODO: いろいろ兼ねられる?
# order controller = `TransferRequestsController`
class InventoryInsController < ApplicationController
  before_action :set_store
  
  before_action :set_inv,
                only: %i[show edit update destroy confirm void]

  #before_action :check_store

  def index
    @invs = Inventory.where(operation: 'in', store_id: @store.id)
  end


  def new
    @inv = Inventories::In.new(store_id: params[:store_id], date: Date.today,
                              description: "Ingreso de ítems")
    2.times { @inv.details.build }
  end

  def create
    @inv = Inventories::In.new(inventory_params.merge(store_id: params[:store_id]))

    if @inv.create
      redirect_to inventory_path(@inv.inventory.id), notice: 'Se ha ingresado correctamente los items.'
    else
      @inv.details.build if @inv.details.empty?
      render :new
    end
  end


  def show
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
    @inv = Inventory.where(operation: 'in', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@inv
  end

  
  def check_store
    Store.find(params[:store_id])
  rescue
    flash[:error] = I18n.t('errors.messages.store.selected')
    redirect_to stores_path and return
  end

  def build_details
    @inv.details.build if @inv.details.empty?
  end

  def inventory_params
    params.require(:inventories_in).permit(
      :store_id, :date, :description,
      inventory_details_attributes: [:item_id, :quantity, :_destroy]
    )
  end
end
