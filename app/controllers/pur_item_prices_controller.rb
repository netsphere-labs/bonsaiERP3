
# /products/:prod_id/pur_item_prices
class PurItemPricesController < ApplicationController
  before_action :set_item
  before_action :set_pur_item_price, only: %i[ show edit update destroy ]

  # GET /pur_item_prices or /pur_item_prices.json
  def index
    @pur_item_prices = PurItemPrice.all
  end

  # GET /pur_item_prices/1 or /pur_item_prices/1.json
  def show
  end

  # GET /pur_item_prices/new
  def new
    @pur_item_price = PurItemPrice.new
  end

  # GET /pur_item_prices/1/edit
  def edit
  end

  # POST /pur_item_prices or /pur_item_prices.json
  def create
    @pur_item_price = PurItemPrice.new(pur_item_price_params)

    respond_to do |format|
      if @pur_item_price.save
        format.html { redirect_to @pur_item_price, notice: "Pur item price was successfully created." }
        format.json { render :show, status: :created, location: @pur_item_price }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @pur_item_price.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /pur_item_prices/1 or /pur_item_prices/1.json
  def update
    respond_to do |format|
      if @pur_item_price.update(pur_item_price_params)
        format.html { redirect_to @pur_item_price, notice: "Pur item price was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @pur_item_price }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @pur_item_price.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /pur_item_prices/1 or /pur_item_prices/1.json
  def destroy
    @pur_item_price.destroy!

    respond_to do |format|
      format.html { redirect_to pur_item_prices_path, notice: "Pur item price was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  
private
  # before_action  
  def set_item
    @item = Item.find(params[:product_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_pur_item_price
    @pur_item_price = PurItemPrice.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pur_item_price_params
      params.fetch(:pur_item_price, {})
    end
end
