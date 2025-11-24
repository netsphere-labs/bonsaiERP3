
# author: Boris Barroso
# email: boriscyber@gmail.com

# - 生産前の支払いは前渡金 (前払金).
# - delivery location での受け渡し後は、支配が移転する
# - 商品の受領前に支払う場合、未着品/買掛金を計上する (モノはまだ使用できない)
# - 入庫時に, 未着品を取り消し, 商品に振り替える. この時点で available
class PurInTransitsController < ApplicationController
  before_action :set_invt, only: %i[show edit update destroy confirm void]

  
  def index
    @orders = PurchaseOrder.where(state: ['confirmed'])
    # TODO: 品目元帳として表示すべき
    @invts = Inventory.where(operation: 'pur_tran')
                     .page(params[:page])
  end

  
  # GET
  # /expenses_inventory_ins/new?store_id=:store_id&expense_id=:expense_id
  def new
    @order = PurchaseOrder.find params[:po_id]
    
    # form object 
    @invt = Expenses::InventoryIn.new(
      Inventory.new order: @order,
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
                Inventory.new order: @order, store_id: @order.store_id,
                              creator_id: current_user.id,
                              operation: 'pur_tran',
                              state: 'draft' )
    @invt.assign inventory_params, params.require(:detail), @order.store_id

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
        # 内部で save!() される
        @invt.confirm! current_user

=begin  not reduce
        @invt.details.each do |inv_detail|
          m = MovementDetail.where(order_id: @invt.order_id,
                                   item_id: inv_detail.item_id).take ||
              MovementDetail.new(order_id: @invt.order_id,
                                 item_id: inv_detail.item_id,
                                 price: inv_detail.price) # new price
          m.balance -= inv_detail.quantity  # not amount
          m.save!
        end
=end
        @invt.order.state = 'in_transit'
        @invt.order.save!

        @invt.gen_je_for_goods_received(current_user)
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

  def set_invt
    @invt = Inventory.where(operation: 'pur_tran', id: params[:id]).take
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
