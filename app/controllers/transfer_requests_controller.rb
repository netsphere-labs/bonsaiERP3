
# inventory transfer requests (order)
# 倉庫の入出庫 (2-steps) は `InventoryOutsController`, `InventoryInsController`
class TransferRequestsController < ApplicationController
  before_action :set_transfer_request,
                only: %i[ show edit update destroy ]

  
  # GET /transfer_requests or /transfer_requests.json
  def index
    @transfer_requests = TransferRequest.order(date: :desc).page(params[:page])
  end

  # GET /transfer_requests/1 or /transfer_requests/1.json
  def show
  end

  # GET /transfer_requests/new
  def new
    # Use the form object.
    @transfer_request = Movements::Form.new(TransferRequest.new date: Date.today,
                                                                state: 'draft')
  end

  # GET /transfer_requests/1/edit
  def edit
  end

  # POST /transfer_requests or /transfer_requests.json
  def create
    @transfer_request = TransferRequest.new(transfer_request_params)

    respond_to do |format|
      if @transfer_request.save
        format.html { redirect_to @transfer_request, notice: "Transfer request was successfully created." }
        format.json { render :show, status: :created, location: @transfer_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transfer_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transfer_requests/1 or /transfer_requests/1.json
  def update
    respond_to do |format|
      if @transfer_request.update(transfer_request_params)
        format.html { redirect_to @transfer_request, notice: "Transfer request was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @transfer_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transfer_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transfer_requests/1 or /transfer_requests/1.json
  def destroy
    @transfer_request.destroy!

    respond_to do |format|
      format.html { redirect_to transfer_requests_path, notice: "Transfer request was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer_request
      @transfer_request = TransferRequest.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def transfer_request_params
      params.fetch(:transfer_request, {})
    end
end
