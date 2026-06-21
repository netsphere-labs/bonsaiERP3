

class CurrenciesController < ApplicationController
  before_action :set_currency, only: %i[ show ]

  # GET /currencies or /currencies.json
  def index
    if params[:text_search].blank? || !params[:reset].blank?
      @search = TextSearch.new
      
      # 日本円が２つある。一つは "銭" があり, exponent = 2 になっている。
      #   -> config/currency_backwards_compatible.json
      # Loader.load_currencies(): 除外する方法がない

      # @note `pagy_array()` has been removed.
      @pagy, @currencies = pagy(:offset, Money::Currency.all.filter {|r|
                !(r.iso_code == "JPY" && r.priority == 100) })
    else
      @search = TextSearch.new params.require(:text_search).permit(:search)
      @pagy, @currencies = pagy(:offset, Money::Currency.all.filter {|r|
                !(r.iso_code == "JPY" && r.priority == 100) && (
                r.name.downcase.index(@search.search.downcase) ||
                r.iso_code.downcase.index(@search.search.downcase) )})
    end
  end

  # GET /currencies/1 or /currencies/1.json
  def show
  end

=begin
  # GET /currencies/new
  def new
    @currency = Currency.new
  end

  # GET /currencies/1/edit
  def edit
  end

  # POST /currencies or /currencies.json
  def create
    @currency = Currency.new(currency_params)

    respond_to do |format|
      if @currency.save
        format.html { redirect_to @currency, notice: "Currency was successfully created." }
        format.json { render :show, status: :created, location: @currency }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /currencies/1 or /currencies/1.json
  def update
    respond_to do |format|
      if @currency.update(currency_params)
        format.html { redirect_to @currency, notice: "Currency was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @currency }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @currency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /currencies/1 or /currencies/1.json
  def destroy
    @currency.destroy!

    respond_to do |format|
      format.html { redirect_to currencies_path, notice: "Currency was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end
=end

  
private

  # Use callbacks to share common setup or constraints between actions.
  def set_currency
    @currency = Money::Currency.find(params.expect(:id))
  end

    # Only allow a list of trusted parameters through.
    def currency_params
      params.fetch(:currency, {})
    end
end
