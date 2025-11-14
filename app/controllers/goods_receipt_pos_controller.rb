
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での購買入庫. PO は `PurchaseOrdersController`
class GoodsReceiptPosController < ApplicationController
  before_action :set_store

  before_action :set_invt, only: %i[show edit update destroy confirm void]

  
  def index
    @orders = PurchaseOrder.where(state: ['confirmed', 'in_transit'],
                                 store_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invts = Inventory.where(operation: 'exp_in', store_id: @store.id)
                     .page(params[:page])
  end

  
  # GET
  # /expenses_inventory_ins/new?store_id=:store_id&expense_id=:expense_id
  def new
    @order = PurchaseOrder.find params[:po_id]
    
    # form object 
    @invt = Expenses::InventoryIn.new(
      Inventory.new store_id: @store.id, order: @order,
                    date: Date.today,
                    description: "Recoger mercadería egreso PO##{@order.id}"
    )
    @invt.build_details_from_order
  end

  
  # POST /expenses_inventory_ins
  # store_id&expense_id=:expense_id
  def create
    @order = PurchaseOrder.find params[:po_id]
    # wrap
    @invt = Expenses::InventoryIn.new(
                Inventory.new store_id: @store.id, order: @order,
                              creator_id: current_user.id,
                              operation: (case @order.state
                                          when 'confirmed'; 'exp_in'
                                          when 'in_transit'; 'pit_in'
                                          else
                                            raise "internal error"
                                          end),
                              state: 'draft' )
    @invt.assign inventory_params, params.require(:detail), @store.id

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
                notice: 'Se realizó el ingreso de inventario.')
  end


  def show
  end


  # POST
  def confirm
    authorize @invt

    begin
      ActiveRecord::Base.transaction do
        @invt.confirm! current_user
        @invt.save!

        # データの安定のために, confirm 時に `order.balance` を減らす
        @invt.details.each do |inv_detail|
          m = MovementDetail.where(order_id: @invt.order_id,
                                   item_id: inv_detail.item_id).take ||
              MovementDetail.new(order_id: @invt.order_id,
                                 item_id: inv_detail.item_id,
                                 price: inv_detail.price) # new price
          m.balance -= inv_detail.quantity  # not amount
          m.save!
        end
        @invt.order.state = 'delivered' # closed
        @invt.order.save!
      
        if @invt.operation == 'exp_in'
          @invt.gen_je_for_goods_received()
        end
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      raise e.inspect
      return
    end
      
    redirect_to({action:"show", id: @invt})
  end

  
  def edit
    # wrap
    @invt = Expenses::InventoryIn.new(@invt)
  end

  
  def update
    # wrap
    @invt = Expenses::InventoryIn.new(@invt)
    @invt.assign inventory_params, params.require(:detail)
    
    # TODO: impl.
  end

  def destroy
    authorize @invt
    
    @invt.destroy!
    # TODO: impl.
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
    @invt = Inventory.where(operation: 'exp_in', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@invt
  end

  
  def inventory_params
    # form object
    params.require(:expenses_inventory_in).permit(
        :description, :date, :account_id,
        #inventory_details_attributes: [:item_id, :quantity]
      )
  end
end
