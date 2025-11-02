
# author: Boris Barroso
# email: boriscyber@gmail.com

# Goods Return Requests (order). 倉庫からの出庫は goods_returns
class GoodsReturnRequestsController < ApplicationController
  
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
