
# author: Boris Barroso
# email: boriscyber@gmail.com

# Goods Return Requests (order). モデル = `GoodsReturnRequest`
# form object = `Expenses::Devolution`
# 倉庫からの出庫は goods_returns
class GoodsReturnRequestsController < ApplicationController
  before_action :set_order,
                only: %i[show edit update destroy confirm void]
  

  def index
    if params[:movements_search].blank? || !params[:reset].blank?
      @search = Movements::Search.new
    else
      #raise params.inspect
      @search = Movements::Search.new params.require(:movements_search)
                                .permit(*Movements::Search.attribute_names)
      # `permit()` returns `Parameters {}`. why?
      @search.state = params.require(:movements_search)['state']
    end
    
    @pagy, @orders = pagy(:offset, @search.search_by_text(GoodsReturnRequest).order(date: :desc))
  end


  def show
  end

  
  # GET /devolutions/:id/new_expense
  def new
    @order = Expenses::Devolution.new(GoodsReturnRequest.new date: Date.today,
                                                             state:'draft')
  end

  
  # POST /devolutions/:id/expense
  def create
    @order = Expenses::Devolution.new(
                    GoodsReturnRequest.new creator_id: current_user.id,
                                           state:'draft')
    @order.assign expense_params, params.request(:detail)

    begin
      ActiveRecord::Base.transaction do 
        # form object 内で同時保存
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end
    
    redirect_to @order.model_obj, notice: "Goods Return Request created."
  end

  def edit
    # wrap
    @order = Expenses::Devolution.new(@order)
  end

  def update
    # wrap
    @order = Expenses::Devolution.new(@order)
  end

  def destroy
  end


  def confirm
  end

  def void
  end

  
private

  # for `before_action()`
  def set_order
    @order = GoodsReturnRequest.find params[:id]
  end
  
    def expense_params
      params.require(:expenses_devolution).permit(*allowed_params)
    end

    def allowed_params
      [:account_id, :account_to_id, :exchange_rate, :amount, :reference, :verification, :date]
    end


    def check_expense
      raise 'Error'  unless @devolution.expense.is_a?(Expense)
    rescue
      render plain: 'Error'
    end
end
