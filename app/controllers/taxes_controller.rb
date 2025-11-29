
# 消費税 / VAT
class TaxesController < ApplicationController
  before_action :set_tax, only: %i[edit update destroy]

  
  def index
    @taxes = Tax.all
  end

  
  # GET /taxes/new
  def new
    @tax = Tax.new
  end

  # POST /taxes
  def create
    @tax = Tax.new tax_params

    if @tax.save
      redirect_to taxes_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  
private

  def set_tax
    # params.expect(): rails8 で導入. permit(), require() を置き換える
    @tax = Tax.find params.expect(:id)
  end
  
  def tax_params
    params.require(:tax).permit(:name, :abbreviation, :percentage)
  end
end
