
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での出荷/納入. 受注 (Sales Order) は `SalesOrdersController`
class DeliveriesController < ApplicationController
  before_action :set_store
  
  before_action :set_invt,
                only: %i[show edit update destroy confirm void]

=begin  
  def index
    @orders = SalesOrder.where(state: ['confirmed'], store_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invts = Inventory.where(operation: 'inc_out', store_id: @store.id)
                     .page(params[:page])
  end
=end

  
  # GET
  # /incomes_inventory_ins/new?store_id=:store_id&income_id=:income_id
  def new
    @order = SalesOrder.find params[:order_id]

    # form object
    @invt = Incomes::InventoryOut.new(
      Inventory.new store_id: @store.id, order: @order,
                    date: Time.zone.today,
                    description: "Entregar mercadería ingreso SO##{@order.id}"
    )
    @invt.build_details_from_order
  end

  
  # POST /incomes_inventory_ins
  # store_id&income_id=:income_id
  def create
    @order = SalesOrder.find params[:order_id]
    # wrap
    @invt = Incomes::InventoryOut.new(
                Inventory.new store_id: @store.id, order: @order,
                              creator_id: current_user.id,
                              operation: 'inc_out',
                              state: 'draft' )
    @invt.assign inventory_params, params.require(:detail), @store.id

    begin
      ActiveRecord::Base.transaction do
        # atomic save in form object
        @invt.save!
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @invt.model_obj},
                notice: 'Se realizó la entrega de inventario.')
  end

  
  def show
  end

  def edit
    @order = @invt.order
    # warp
    @invt = Incomes::InventoryOut.new(@invt)
  end

  
  def update
    @order = @invt.order
    # warp
    @invt = Incomes::InventoryOut.new(@invt)
    @invt.assign inventory_params, params.require(:detail), @store.id
    
    begin
      ActiveRecord::Base.transaction do
        # atomic save in form object
        @invt.save!
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @invt.model_obj},
                notice: 'Se realizó la entrega de inventario.')
  end

  
  def destroy
    authorize @invt
    
    ActiveRecord::Base.transaction do
      InventoryDetail.where(inventory_id: @invt.id).delete_all
      @invt.destroy!
    end

    redirect_to({action:"index"})
  end


  # POST
  def confirm
    authorize @invt

    begin
      ActiveRecord::Base.transaction do
        # 内部で save! される
        @invt.confirm! current_user #, current_organisation

        # データの安定のために, confirm 時に `order.balance` を減らす
        # TODO:
        #   To prevent double submissions, the balances is subtracted even in
        #   draft state. It also needs to update them when the voucher is updated.
        
        @invt.details.each do |invt_detail|
          m = OrderDetail.where(order_id: @invt.order_id,
                                   item_id: invt_detail.item_id).take ||
              OrderDetail.new(order_id: @invt.order_id,
                                 item_id: invt_detail.item_id,
                                 price: invt_detail.txn_price) # new price
          m.balance -= invt_detail.quantity  # not amount
          m.save!
        end
        @invt.order.state = 'delivered' # closed
        @invt.order.save!

        @invt.gen_je_for_delivery(current_user)
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      raise e.inspect
      return
    end
      
    redirect_to({action:"show", id: @invt})
  end


  # POST
  def void
    authorize @invt

    # TODO: impl.
  end

  
private

  def set_store
    @store = Store.find params[:store_id]
  end

  def set_invt
    @invt = Inventory.where(operation: 'inc_out', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@invt
  end


  def inventory_params
    # form object
    params.require(:incomes_inventory_out).permit(
        :description, :date, :account_id, 
      #inventory_details_attributes: [:item_id, :quantity]
    )
  end
  
end
