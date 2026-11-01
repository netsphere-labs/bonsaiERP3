
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での Inventory transfer in two-steps - out   TODO: いろいろ兼ねられる?
# order は `TransferRequestsController`
class InventoryOutsController < ApplicationController
  before_action :set_store, only: %i[new create]

  before_action :set_invt, only: %i[show edit update destroy confirm void]

=begin
  def index
    # `partial` を "shipped" の意味で使う
    @orders = TransferRequest.where(state:['confirmed'], #, 'partial'],
                                    store_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invs = Inventory.where(operation: 'out', store_id: @store.id)
                     .page(params[:page])
  end
=end
  
  def new
    @order = TransferRequest.find params[:order_id]

    # form object
    @invt = Inventories::Out.new(
      Inventory.new store_id: @store.id, order: @order,
                date: Date.today,
                description: "Egreso de ítems: transfer request ##{@order.id}"
    )
    @invt.build_details_from_order
  end

  
  def create
    @order = TransferRequest.find params[:order_id]
    # wrap
    @invt = Inventories::Out.new(
      Inventory.new store_id: @store.id, order: @order,
                    store_to_id: @order.trans_to_id,
                    creator_id: current_user.id,
                    operation: 'out',
                    state: 'draft' )
    @invt.assign inventory_params, params.require(:detail), @store.id, current_organisation

    begin
      ActiveRecord::Base.transaction do
        # atomic save in form object
        @invt.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @invt.model_obj},
                notice: 'Se ha egresado correctamente los items.' )
  end


  def show
    @store = @invt.store
  end

  def edit
    @order   = @invt.order
    @store   = @invt.store
    # wrap
    @invt = Inventories::Out.new(@invt)
  end

  
  def update
    @order   = @invt.order
    @store   = @invt.store
    # wrap
    @invt = Inventories::Out.new(@invt)
    raise "TODO: impl."
  end

  
  def destroy
    raise NotImplementedError # TODO: impl.
  end

  # POST
  def confirm
    begin
      ActiveRecord::Base.transaction do
        # 内部で save! される
        @invt.confirm! current_user #, current_organisation

        @invt.order.state = 'in_transit' # open
        @invt.order.save!

        # not need
        #@invt.gen_je_for_delivery(current_user, current_organisation)
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      raise e.inspect
      return
    end
      
    redirect_to({action:"show", id: @invt})
  end

  def void
  end

  
private

  def set_store
    @store = Store.find params[:store_id]
  end

  def set_invt
    @invt = Inventory.where(operation: 'out', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@invt
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
    params.require(:inventories_out).permit(
      :store_id, :date, :description
      #inventory_details_attributes: [:item_id, :quantity, :_destroy]
    )
  end
end
