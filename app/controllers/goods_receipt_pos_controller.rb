
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での購買入庫. PO は `PurchaseOrdersController`
class GoodsReceiptPosController < ApplicationController
  before_action :set_store

  before_action :set_inv, only: %i[show edit update destroy confirm void]

  
  def index
    @orders = PurchaseOrder.where(state: ['confirmed', 'partial'],
                                 store_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invs = Inventory.where(operation: 'exp_in', store_id: @store.id)
                     .page(params[:page])
  end

  
  # GET
  # /expenses_inventory_ins/new?store_id=:store_id&expense_id=:expense_id
  def new
    @order = PurchaseOrder.find params[:po_id]
    
    # form object 
    @inv = Expenses::InventoryIn.new(
      Inventory.new store_id: @store.id, order: @order,
                    date: Date.today,
                    description: "Recoger mercadería egreso PO##{@order.id}"
    )
    @inv.build_details_from_order
  end

  
  # POST /expenses_inventory_ins
  # store_id&expense_id=:expense_id
  def create
    @order = PurchaseOrder.find params[:po_id]
    # wrap
    @inv = Expenses::InventoryIn.new(
                Inventory.new store_id: @store.id, order: @order,
                              creator_id: current_user.id,
                              operation: 'exp_in',
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
                notice: 'Se realizó el ingreso de inventario.')
  end


  def show
  end


  # POST
  def confirm
    authorize @inv

    # journal entry
    # 債権債務が絡む取引は、都度つど仕訳を作る
    amt = {}
    @inv.details.each do |detail|
      # 三分法でやってみる
      amt[detail.item.accounting.purchase_ac_id] =
                        (amt[detail.item.accounting.purchase_ac_id] || 0) +
                        detail.price * detail.quantity  # ここは機能通貨
    end

    begin
      ActiveRecord::Base.transaction do
        @inv.confirm! current_user
        @inv.save!

        # データの安定のために, confirm 時に `order.balance` を減らす
        @inv.details.each do |inv_detail|
          m = MovementDetail.where(order_id: @inv.order_id,
                                   item_id: inv_detail.item_id).take ||
              MovementDetail.new(order_id: @inv.order_id,
                                 item_id: inv_detail.item_id,
                                 price: inv_detail.price) # new price
          m.balance -= inv_detail.quantity  # not amount
          m.save!
        end
        @inv.order.update_state!
      
        entry_no = rand(2_000_000_000)
        # Dr.
        sum_amt = 0
        amt.each do |pur_ac_id, a|
          # TODO: 金額は取引通貨でなければならない。が、機能通貨建てになっている
          #       受入れのときに取引通貨と両方保存が必要
          
          r = AccountLedger.new date: @inv.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: pur_ac_id,  # Dr.
                            amount: a,  
                            currency: @inv.order.currency,
                            description: "goods receipt po",
                            creator_id: current_user.id,
                            status: 'approved',
                            inventory_id: @inv.id
          r.save!
          sum_amt += a
        end
        # Cr.
        r = AccountLedger.new date: @inv.date, entry_no: entry_no,
                            operation: 'trans',
                            account_id: @inv.account_id,
                            amount: -sum_amt,  # 取引通貨, 貸方マイナス
                            currency: @inv.order.currency,
                            description: "goods receipt po",
                            creator_id: current_user.id,
                            status: 'approved',
                            inventory_id: @inv.id
        r.save!
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      raise e.inspect
      return
    end
      
    redirect_to({action:"show", id: @inv})
  end

  
  def edit
    # wrap
    @inv = Expenses::InventoryIn.new(@inv)
  end

  
  def update
    # wrap
    @inv = Expenses::InventoryIn.new(@inv)
    @inv.assign inventory_params, params.require(:detail)
    
    # TODO: impl.
  end

  def destroy
    authorize @inv
    
    @inv.destroy!
    # TODO: impl.
  end

  
  # POST
  def void
    authorize @inv

    # TODO: impl.
  end

  
private

  def set_store
    @store = Store.find params[:store_id]
  end

  def set_inv
    @inv = Inventory.where(operation: 'exp_in', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@inv
  end

  
  def inventory_params
    # form object
    params.require(:expenses_inventory_in).permit(
        :description, :date, :account_id,
        #inventory_details_attributes: [:item_id, :quantity]
      )
  end
end
