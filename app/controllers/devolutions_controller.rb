
# author: Boris Barroso
# email: boriscyber@gmail.com

# Customer Return Request (order). model = `CustomerReturnRequest`
# form object = `Incomes::Devolution`
# 倉庫での顧客返品の受取りは `CustomerReturnsController`
class DevolutionsController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy]

  
  def index
    @orders = CustomerReturnRequest.page(params[:page])
  end

  
  # GET /devolutions/:id/new_income
  def new
    @devolution = Incomes::Devolution.new(account_id: params[:id], date: Date.today)
    check_income
  end

  # POST /devolutions/:id/income
  def create
    @devolution = Incomes::Devolution.new(income_params)
    check_income

    if @devolution.pay_back
      flash[:notice] = 'La devolución se realizo correctamente.'
      render 'income.js'
    else
      render :new_income
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
=begin
  # GET /devolutions/:id/new_expense
  def new_expense
    @devolution = Expenses::Devolution.new(account_id: params[:id], date: Date.today)
    check_expense
  end

  # POST /devolutions/:id/expense
  def expense
    @devolution = Expenses::Devolution.new(expense_params)
    check_expense

    if @devolution.pay_back
      flash[:notice] = 'La devolución se realizo correctamente.'
      render 'expense.js'
    else
      render :new_expense
    end
  end
=end

  
  private

    def income_params
      params.require(:incomes_devolution).permit(*allowed_params)
    end

    def expense_params
      params.require(:expenses_devolution).permit(*allowed_params)
    end

    def allowed_params
      [:account_id, :account_to_id, :exchange_rate, :amount, :reference, :verification, :date]
    end

    def check_income
      raise 'Error'  unless @devolution.income.is_a?(Income)
    rescue
      render plain: 'Error'
    end

    def check_expense
      raise 'Error'  unless @devolution.expense.is_a?(Expense)
    rescue
      render plain: 'Error'
    end
end
