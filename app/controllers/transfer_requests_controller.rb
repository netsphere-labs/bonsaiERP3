
# inventory transfer requests (order). model = `TransferRequest`
# 倉庫の入出庫 (2-steps) は `InventoryOutsController`, `InventoryInsController`
class TransferRequestsController < ApplicationController
  before_action :set_order, only: %i[show edit update destroy confirm void]

  
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
    # wrap
    @order = Movements::Form.new(@order)
  end

  
  # POST /transfer_requests or /transfer_requests.json
  def create
    # wrap
    @order = Movements::Form.new(TransferRequest.new creator_id: current_user.id,
                                                     state: 'draft' )
    @order.assign transfer_request_params, params.require(:detail)

    begin
      ActiveRecord::Base.transaction do
        # form object 内で同時保存する
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity 
      return
    end
    
    redirect_to @order.model_obj,
                notice: "Transfer request was successfully created." 
  end

  
  # PATCH/PUT /transfer_requests/1 or /transfer_requests/1.json
  def update
    # wrap
    @order = Movements::Form.new(@order)
    @order.assign(xxx) # TODO: impl.
    
    begin
      ActiveRecord::Base.transaction do
        # form object 内で同時保存する
        @order.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity 
      return
    end
    
    redirect_to @order.model_obj,
                notice: "Transfer request was successfully updated.",
                status: :see_other 
  end

  
  # DELETE /transfer_requests/1 or /transfer_requests/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to transfer_requests_path, notice: "Transfer request was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST
  def confirm
    
  end

  # POST
  def void
  end

  
private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = TransferRequest.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def transfer_request_params
    # form object
    params.require(:movements_form)
          .permit(:date, :ship_date, :store_id, :delivery_date, :trans_to_id)
  end
end
