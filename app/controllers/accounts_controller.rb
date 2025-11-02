
# Chart of Accounts
class AccountsController < ApplicationController
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts or /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1 or /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts or /accounts.json
  def create
    @account = Account.new(params.require(:account)
                           .permit(:name, :active, :currency, :description, :subtype) )
    @account.creator_id = current_user.id
    
    if @account.save
      redirect_to @account, notice: "Account was successfully created." 
    else
      render :new, status: :unprocessable_entity 
    end
  end

  
  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: "Account was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy!

    redirect_to accounts_path,
                notice: "Account was successfully destroyed.",
                status: :see_other 
  end

  
private

  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def account_params
    params.require(:account).permit(:name, :active, :description)
  end
end
