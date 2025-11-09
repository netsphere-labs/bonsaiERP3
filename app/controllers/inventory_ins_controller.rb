
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での Inventory transfer in two-steps - in   TODO: いろいろ兼ねられる?
# order controller = `TransferRequestsController`
class InventoryInsController < ApplicationController
  before_action :set_store
  
  before_action :set_inv, only: %i[show edit update destroy confirm void]


  def index
    # `partial` を "shipped" の意味で使う
    @orders = TransferRequest.where(state:['partial'], trans_to_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invs = Inventory.where(operation: 'in', store_id: @store.id)
                     .page(params[:page])
  end


  def new
    @order = TransferRequest.find params[:order_id]

    # form object
    @inv = Inventories::In.new(
      Inventory.new store_id: @store.id, order: @order,
                    date: Date.today,
                    description: "Ingreso de ítems ##{@order.id}"
    )
    @inv.build_details_from_order
  end

  
  def create
    @order = TransferRequest.find params[:order_id]
    # wrap
    @inv = Inventories::In.new(
      Inventory.new store_id: @store.id, order: @order,
                    creator_id: current_user.id,
                    operation: 'in',
                    state: 'draft' )
    @inv.assign inventory_params, params.require(:detail), @store.id

    begin
      ActiveRecord::Base.transaction do
        # atomic save in form object
        @inv.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to({action:"show", id: @inv.model_obj},
                notice: 'Se ha ingresado correctamente los items.' )
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

=begin  
  def check_store
    Store.find(params[:store_id])
  rescue
    flash[:error] = I18n.t('errors.messages.store.selected')
    redirect_to stores_path and return
  end

  def build_details
    @inv.details.build if @inv.details.empty?
  end
=end
  
  def inventory_params
    params.require(:inventories_in).permit(
      :store_id, :date, :description
      #inventory_details_attributes: [:item_id, :quantity, :_destroy]
    )
  end
end
