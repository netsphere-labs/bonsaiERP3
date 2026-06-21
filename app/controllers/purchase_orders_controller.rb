
# author: Boris Barroso
# email: boriscyber@gmail.com

# 発注 (order). モデル = `PurchaseOrder`. form object = `Orders::Form`
# 購買入庫は `GoodsReceiptPosController`
class PurchaseOrdersController < ApplicationController
  include Controllers::TagSearch

  before_action :set_order,
                only: %i[show edit update destroy confirm void inventory ]

  # GET /purchase_orders/
  def index
    if params[:orders_search].blank? || !params[:reset].blank?
      @search = Orders::Search.new
    else
      #raise params.inspect
      @search = Orders::Search.new params.require(:orders_search)
                                .permit(*Orders::Search.attribute_names)
      # `permit()` returns `Parameters {}`. why?
      @search.state = params.require(:orders_search)['state']
    end

    @pagy, @orders = pagy(:offset,
                @search.search_by_text(PurchaseOrder).order(date: :desc))
  end

  
  # GET /expenses/1
  def show
    #@expense = present Expense.find(params[:id])
  end

  # GET /expenses/new
  def new
    # Use the form object.
    # TODO: default currency = partner's one.
    @order = Orders::Form.new(PurchaseOrder.new date: Time.zone.today,
                                                   state: 'draft')
    #@order_details = []
  end

  
  # POST /expenses
  def create
    # the form object
    @order = Orders::Form.new(
                PurchaseOrder.new creator_id: current_user.id,
                                  state: 'draft' )
    @order.assign expense_params, params.require(:detail)

    begin
      ActiveRecord::Base.transaction do
        # form object 内で同時保存する
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      #raise @order.errors.inspect
      render :new, status: :unprocessable_entity
      return
    end
      
    redirect_to @order.model_obj, notice: 'Se ha creado un Egreso.'
  end

  
  # GET /expenses/1/edit
  def edit
    # wrap
    @order = Orders::Form.new(@order)
  end


  # PATCH /expenses/:id
  def update
    # wrap
    @order = Orders::Form.new(@order)
    @order.assign expense_params, params.require(:detail)
    begin
      ActiveRecord::Base.transaction do
        # form object 内で同時保存する
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity
      return
    end

    
    redirect_to @order.model_obj, notice: 'El Egreso fue actualizado!.'
  end


  # PATCH /expenses/1/approve
  # Method to approve an expense
  def confirm
    authorize @order
    
    @order.confirm! current_user
    if @order.save
      flash[:notice] = "La nota de venta fue aprobada."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to purchase_order_path(@order)
  end

  
  # PATCH /expenses/:id/approve
  # Method that nulls or enables inventory
  def inventory
    @expense.inventory = !@expense.inventory?
    @expense.extras = @expense.extras.symbolize_keys

    if @expense.save
      txt = @expense.inventory? ? 'activo' : 'desactivó'
      flash[:notice] = "Se #{txt} los inventarios."
    else
      flash[:error] = 'Exisition un error'
    end

    redirect_to expense_path(@expense.id, anchor: 'items')
  end

  
  # PATCH /incomes/:id/null
  def void
    authorize @order
    
    if @expense.null!
      redirect_to expense_path(@expense), notice: 'Se anulo correctamente el egreso.'
    else
      redirect_to expense_path(@expense), error: 'Existio un error al anular el egreso.'
    end
  end


  # DELETE
  def destroy
    authorize @order
    
    @order.destroy!
    redirect_to purchase_orders_path,
                notice: "PO was successfully destroyed.", status: :see_other 
  end

=begin   分納を (まだ) サポートしていないため、強制 close は不要
  # POST
  def force_close
    raise "TODO: impl"
  end
=end  

  
private

=begin
  # Creates or approves a Expenses::Form instance
    def create_or_approve
      if params[:commit_approve]
        @es.create_and_approve
      else
        @es.create
      end
    end

    def update_or_approve
      if params[:commit_approve]
        @es.update_and_approve(expense_params)
      else
        @es.update(expense_params)
      end
    end
=end

    def quick_expense_params
     params.require(:expenses_quick_form).permit(*movement_params.quick_income)
    end

  def expense_params
    # form object
    params.require(:orders_form)
          .permit(:contact_id, :date, :currency, :ship_date, :delivery_loc,
                  :incoterms, :delivery_date, :store_id)
  end

  # for `before_action()`
  def set_order
    @order = PurchaseOrder.find params[:id]
  end

=begin  
    # Method to search expenses on the index
    def search_expenses
      if tag_ids
        @expenses = Expenses::Query.index_includes Expense.any_tags(*tag_ids)
      else
        @expenses = Expenses::Query.new.index(params).order('date desc, accounts.id desc')
      end

      set_expenses_filters
      @expenses = @expenses.page(@page)
    end
=end
  
    def set_expenses_filters
      [:approved, :error, :due, :nulled, :inventory].each do |filter|
        @expenses = @expenses.send(filter)  if params[filter].present?
      end
    end

    def set_index_params
      params[:all] = true unless [:approved, :error, :nulled, :due, :inventory].any? {|v| params[v].present? }
    end
end
