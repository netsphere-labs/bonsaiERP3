
# author: Boris Barroso
# email: boriscyber@gmail.com

# - 生産前の支払いは前渡金 (前払金).
# - delivery location での受け渡し後は、支配 and risk が移転する
# - 商品の受領前に支払う場合、未着品/買掛金を計上する (モノはまだ使用できない)
# - 入庫時に, 未着品を取り消し, 商品に振り替える. この時点で available
class PurInTransitsController < ApplicationController
  before_action :set_invt, only: %i[show edit update destroy confirm void]

=begin  
  def index
    #@orders = PurchaseOrder.where(state: ['confirmed'])
    # TODO: 品目元帳として表示すべき
    @pagy, @invts = pagy(:offset, Inventory.where(operation: 'pur_tran'))
  end
=end
  
  
  # GET
  # /expenses_inventory_ins/new?store_id=:store_id&expense_id=:expense_id
  def new
    @order = PurchaseOrder.find params[:po_id]
    
    # form object 
    @invt = Movements::ExpenseIn.new(
      Inventory.new order: @order,
                    date: Time.zone.today,
                    description: "Recoger mercadería egreso PO##{@order.id}"
    )
    @invt.build_details_from_order

    @invoice = Invoice.new inv_type: 'purchase',
                           partner_id: @order.contact_id,
                           curr_code: @order.currency,
                           order: @order
  end

  
  # POST /expenses_inventory_ins
  # store_id&expense_id=:expense_id
  def create
    @order = PurchaseOrder.find params[:po_id]
    # wrap
    @invt = Movements::ExpenseIn.new(
                Inventory.new order: @order, store_id: @order.store_id,
                              creator_id: current_user.id,
                              operation: 'pur_tran',
                              curr_code: @order.currency,
                              state: 'draft' )
    @invt.assign inventory_params, params.require(:detail), @order.store_id, current_organisation

    @invoice = Invoice.new(
                params.require(:movements_expense_in).require(:invoice)
                      .permit(:due_date, :bp_bank_account_id, :lock_version))
    @invoice.assign_attributes partner_id: @order.contact_id,
                               curr_code: @order.currency,
                               date: @invt.date,
                               status: 'draft',
                               doc_no: nil,
                               inv_type: 'purchase',
                               order: @order
    begin
      ActiveRecord::Base.transaction do
        @invoice.amount_total = @invt.details.reduce(0.0) {|r, item| r + item.txn_amount}
        @invoice.save!
        # atomic save in form object
        @invt.model_obj.invoice_id = @invoice.id
        @invt.save!

        # copy to invoice
        @invt.details.each do |detail|
          InvoiceGood.create! invoice_id: @invoice.id,
                              item_id: detail.item_id,
                              qty: detail.quantity,
                              txn_amount: detail.txn_amount
        end
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @invt.model_obj},
                notice: 'Se realizó el ingreso de inventario.')
  end


  def show
  end


  def edit
    @order = @invt.order
    @invoice = @invt.invoice
    # wrap
    @invt = Movements::ExpenseIn.new(@invt)
  end

  
  def update
    @order = @invt.order
    @invoice = @invt.invoice
    # wrap
    @invt = Movements::ExpenseIn.new(@invt)
    @invt.assign inventory_params, params.require(:detail), @order.store_id, current_organisation
    
    @invoice.assign_attributes( params.require(:movements_expense_in)
                        .require(:invoice)
                        .permit(:due_date, :bp_bank_account_id, :lock_version))
    begin
      ActiveRecord::Base.transaction do
        @invoice.amount_total = @invt.details.reduce(0.0) {|r, item| r + item.txn_amount}
        @invoice.save!
        # atomic save in form object
        @invt.save!

        # copy to invoice
        InvoiceGood.where(invoice_id: @invoice.id).delete_all
        @invt.details.each do |detail|
          InvoiceGood.create! invoice_id: @invoice.id,
                              item_id: detail.item_id,
                              qty: detail.quantity,
                              txn_amount: detail.txn_amount
        end
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity
      return
    end
      
    redirect_to({action:"show", id: @invt.model_obj},
                notice: 'Se realizó el ingreso de inventario.')
  end


  # POST
  def confirm
    authorize @invt

    begin
      ActiveRecord::Base.transaction do
        # 内部で save!() される
        @invt.confirm! current_user

        @invt.invoice.status = "confirmed"
        @invt.invoice.save!

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

        # Dr. "未着品" goods in transit
        @invt.gen_je_for_goods_received(current_user, current_organisation)
      end # transaction
    rescue ActiveRecord::RecordInvalid => e
      raise e.inspect
      return
    end
      
    redirect_to({action:"show", id: @invt})
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
    params.require(:movements_expense_in).permit(
        :description, :date, :account_id,
        #inventory_details_attributes: [:item_id, :quantity]
      )
  end
end
