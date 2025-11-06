
# inventory transfer requests (order). model = `TransferRequest`
# 倉庫の入出庫 (2-steps) は `InventoryOutsController`, `InventoryInsController`
class TransferRequestsController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]

  
  # GET /transfer_requests or /transfer_requests.json
  def index
    @orders = TransferRequest.order(date: :desc).page(params[:page])
  end

  # GET /transfer_requests/1 or /transfer_requests/1.json
  def show
  end

  # GET /transfer_requests/new
  def new
    # Use the form object.
    @order = Movements::Form.new(TransferRequest.new date: Date.today,
                                                                state: 'draft')
  end

  # GET /transfer_requests/1/edit
  def edit
  end

  # POST /transfer_requests or /transfer_requests.json
  def create
    @order = TransferRequest.new(transfer_request_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Transfer request was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfer_requests/1 or /transfer_requests/1.json
  def update
    respond_to do |format|
      if @order.update(transfer_request_params)
        format.html { redirect_to @order, notice: "Transfer request was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfer_requests/1 or /transfer_requests/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to transfer_requests_path, notice: "Transfer request was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  
private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = TransferRequest.find(params.expect(:id))
  end

    # Only allow a list of trusted parameters through.
    def transfer_request_params
      params.fetch(:transfer_request, {})
    end
end
