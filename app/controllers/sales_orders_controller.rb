
# author: Boris Barroso
# email: boriscyber@gmail.com

# Sales Orders. model = `SalesOrder`. form object = `Movements::Form`
# 倉庫からの出庫は `DeliveriesController`
class SalesOrdersController < ApplicationController
  include Controllers::TagSearch
  include Controllers::Print

  before_action :set_order,
                only: [:show, :edit, :update, :destroy, :confirm, :void, :inventory ]

  
  # GET /incomes
  def index
    if params[:movements_search].blank? || !params[:reset].blank?
      @search = Movements::Search.new
    else
      @search = Movements::Search.new params.require(:movements_search)
                                        .permit(*Movements::Search.attribute_names)
    end
    
    @orders = @search.search_by_text(SalesOrder).order(date: :desc).page(params[:page])
  end

  
  # GET /incomes/1
  def show
    #@income = present Income.find(params[:id])

    #respond_to do |format|
    #  format.html
    #  format.print
    #  format.pdf { print_pdf 'show.print', "Ingreso-#{@income}" }
    #end
  end

  
  # GET /incomes/new
  def new
    # Use form object.
    @order = Movements::Form.new(SalesOrder.new date: Time.now, state: 'draft')
    #@order_details = []
  end

  
  # GET /incomes/1/edit
  def edit
    # wrap
    @order = Movements::Form.new(@order)
  end

  
  # POST /incomes
  def create
    # ここでフォームオブジェクトを使っている
    @order = Movements::Form.new(SalesOrder.new creator_id: current_user.id,
                                                state: 'draft' )                          
    @order.assign income_params, params.require(:detail)
    
    begin
      ActiveRecord::Base.transaction do
        # form object 内で同時保存
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      #raise @order.errors.inspect
      render :new, status: :unprocessable_entity
      return
    end
    
    redirect_to @order.model_obj, notice: 'Se ha creado un Ingreso.'
  end

  
  # PATCH /incomes/:id
  def update
    # wrap
    @order = Movements::Form.new(@order)
    @order.assign income_params, params.require(:detail)
    
    if update_or_approve
      redirect_to income_path(@is.income), notice: 'El Ingreso fue actualizado!.'
    else
      render :edit, status: :unprocessable_entity 
    end
  end

  
  # PATCH /incomes/:id/approve
  # Method to approve an income
  def confirm
    authorize @order

    @order.confirm! current_user
    if @order.save
      flash[:notice] = "El Ingreso fue aprobado."
    else
      flash[:error] = "Existio un problema con la aprobación."
    end

    redirect_to sales_order_path(@order)
  end

  
  # PATCH /incomes/:id/approve
  # Method that nulls or enables inventory
  def inventory
    @income.inventory = !@income.inventory?

    if @income.save
      txt = @income.inventory? ? 'activo' : 'desactivó'
      flash[:notice] = "Se #{txt} los inventarios."
    else
      flash[:error] = "Exisition un error modificando el estado de inventarios."
    end

    redirect_to income_path(@income.id, anchor: 'items')
  end

  
  # PATCH /incomes/:id/null
  def void
    authorize @order
    
    if @income.null!
      redirect_to income_path(@income), notice: 'Se anulo correctamente el ingreso.'
    else
      redirect_to income_path(@income), error: 'Existio un error al anular el ingreso.'
    end
  end


  def destroy
    authorize @order
    
    @order.destroy!
    #TODO impl.
  end

    
private

    # Creates or approves a ExpenseService instance
    def create_or_approve
      if params[:commit_approve]
        @is.create_and_approve
      else
        @is.create
      end
    end

    def update_or_approve
      if params[:commit_approve]
        @is.update_and_approve(income_params)
      else
        @is.update(income_params)
      end
    end

  def income_params
    # form object
    params.require(:movements_form)
          .permit(:contact_id, :date, :store_id, :ship_date, :currency)
  end


  # before_action()
  def set_order
    @order = SalesOrder.find params[:id]
  end

=begin
    # Method to search incomes on the index
    def search_incomes
      if tag_ids
        @incomes = Incomes::Query.index_includes Income.any_tags(*tag_ids)
      else
        @incomes = Incomes::Query.new.index(params).order('date desc, accounts.id desc')
      end

      set_incomes_filters
      @incomes = @incomes.page(@page)
    end
=end
  
    def set_incomes_filters
      [:approved, :error, :due, :nulled, :inventory].each do |filter|
        @incomes = @incomes.send(filter)  if params[filter].present?
      end
    end

    def set_index_params
      params[:all] = true unless [:approved, :error, :nulled, :due, :inventory].any? { |key| params[key].present? }
    end
end
