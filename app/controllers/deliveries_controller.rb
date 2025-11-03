
# author: Boris Barroso
# email: boriscyber@gmail.com

# 倉庫での出荷/納入. 受注 (Sales Order) は `SalesOrdersController`
class DeliveriesController < ApplicationController
  before_action :set_store
  
  before_action :set_inv,
                only: %i[show edit update destroy confirm void]

  
  def index
    @orders = SalesOrder.confirmed.where(store_id: @store.id)
    # TODO: 品目元帳として表示すべき
    @invs = Inventory.where(operation: 'inc_out', store_id: @store.id)
                     .page(params[:page])
  end

  
  # GET
  # /incomes_inventory_ins/new?store_id=:store_id&income_id=:income_id
  def new
    @order = SalesOrder.find params[:order_id]

    # form object
    @inv = Incomes::InventoryOut.new(
      Inventory.new store_id: @store.id, order: @order,
                    date: Date.today,
                    description: "Entregar mercadería ingreso SO##{@order.id}"
    )
    @inv.build_details_from_order
  end

  
  # POST /incomes_inventory_ins
  # store_id&income_id=:income_id
  def create
    @order = SalesOrder.find params[:order_id]
    # wrap
    @inv = Incomes::InventoryOut.new(
                Inventory.new store_id: @store.id, order: @order,
                              creator_id: current_user.id,
                              operation: 'inc_out',
                              state: 'draft' )
    @inv.assign inventory_params, params.require(:detail), @store.id

    begin
      ActiveRecord::Base.transaction do
        # atomic save in form object
        @inv.save!

        # TODO:
        # To prevent double submissions, the balances is subtracted even in
        # draft state. It also needs to update them when updating. This is not
        # efficient.
        
        # subtract from the order balance.
        @inv.model_obj.details.each do |inv_detail|
          m = MovementDetail.where(order_id: @inv.model_obj.order_id,
                                   item_id: inv_detail.item_id).take ||
              MovementDetail.new(order_id: @inv.model_obj.order_id,
                                 item_id: inv_detail.item_id,
                                 price: inv_detail.price) # new price
          m.balance -= inv_detail.quantity
          m.save!
        end
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @inv.model_obj},
                notice: 'Se realizó la entrega de inventario.')
  end

  
  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end


  # POST
  def confirm
    authorize @inv

    # journal entry
    # TODO: 1件ごとに作っていては件数がバカにならない. 集約して, 夜間バッチに
    #       するか?
    amt = {}
    @inv.details.each do |detail|
      amt[detail.item.accounting.revenue_ac_id] =
                        (amt[detail.item.accounting.revenue_ac_id] || 0) +
                        detail.price * detail.quantity
    end

    begin
      ActiveRecord::Base.transaction do
        @inv.confirm! current_user
        @inv.save!

        # Cr.
        sum_amt = 0
        amt.each do |rev_ac_id, a|
          r = AccountLedger.new date: @inv.date,
                            operation: 'trans',
                            account_id: rev_ac_id,  # Cr.
                            amount: -a,  # 取引通貨, 貸方マイナス
                            currency: @inv.order.currency,
                            description: "delivery",
                            creator_id: current_user.id,
                            status: 'approved',
                            inventory_id: @inv.id
          r.save!
          sum_amt += a
        end
        # Dr.
        r = AccountLedger.new date: @inv.date,
                            operation: 'trans',
                            account_id: @inv.account_id,
                            amount: sum_amt,  # 取引通貨
                            currency: @inv.order.currency,
                            description: "delivery",
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
    @inv = Inventory.where(operation: 'inc_out', id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@inv
  end


  def inventory_params
    # form object
    params.require(:incomes_inventory_out).permit(
        :description, :date, :account_id, 
      #inventory_details_attributes: [:item_id, :quantity]
    )
  end
  
end
