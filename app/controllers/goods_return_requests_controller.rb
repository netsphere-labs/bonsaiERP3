
# author: Boris Barroso
# email: boriscyber@gmail.com

# Goods Return Requests (order). モデル = `GoodsReturnRequest`
# form object = `Expenses::Devolution`
# 倉庫からの出庫は goods_returns
class GoodsReturnRequestsController < ApplicationController
  before_action :set_order,
                only: %i[show edit update destroy confirm void]
  
=begin
  # GET /devolutions/:id/new_income
  def new_income
    @devolution = Incomes::Devolution.new(account_id: params[:id], date: Date.today)
    check_income
  end

  # POST /devolutions/:id/income
  def income
    @devolution = Incomes::Devolution.new(income_params)
    check_income

    if @devolution.pay_back
      flash[:notice] = 'La devolución se realizo correctamente.'
      render 'income.js'
    else
      render :new_income
    end
  end
=end

  def index
    @orders = GoodsReturnRequest.order(date: :desc).page(params[:page])
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
