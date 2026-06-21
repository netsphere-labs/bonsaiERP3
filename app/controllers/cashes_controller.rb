
# author: Boris Barroso
# email: boriscyber@gmail.com

# 自社の銀行口座・現金マスタ
class CashesController < ApplicationController
  before_action :set_cash, only: [:show, :edit, :update, :destroy]

  # GET /banks
  def index
    @cashes = Cash.eager_load(:account).order('name ASC')
  end

  # GET /banks/1
  def show
  end

  # GET /banks/new
  def new
    #ac = Account.new accountable: Cash.new(),
    # TODO: 組織の機能通貨を初期値にする
    @cash = Cash.new account: Account.new(currency: "JPY", active:true,
                                          subtype: 'CASH')
  end

  
  # GET /banks/1/edit
  def edit
  end
  
  # POST /banks
  def create
    @cash = Cash.new account: Account.new(params.require(:cash)
                                .require(:account)
                                .permit(:name, :currency, :active, :description))
    @cash.assign_attributes create_bank_params
    begin
      ActiveRecord::Base.transaction do 
        # @cash.save だと cash しか作られない!
        @cash.save!
        @cash.account.accountable = @cash
        @cash.account.subtype = 'CASH'
        @cash.account.creator_id = current_user.id
        @cash.account.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      #raise e.record.inspect
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to @cash, notice: 'La cuenta de banco fue creada.'
  end

  
  # PUT /banks/1
  def update
    @cash.assign_attributes(update_bank_params)
    @cash.account.assign_attributes(params.require(:cash).require(:account)
                                      .permit(:name, :active, :description))
                    
    ActiveRecord::Base.transaction do
      @cash.save!
      @cash.account.save!
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity 
      return
    end

    redirect_to @cash, notice: 'Se actualizo  correctamente la cuenta de banco.'
  end

  
  # Presents money accounts json method
  # GET /banks/money
  def money
    render json: Account.active.money.where(currency: current_organisation.currency)
      .to_json(only: [:id, :currency, :name, :type])
  end

  # DELETE /banks/1
  # DELETE /banks/1.xml
  def destroy
    @cash.destroy!
    redirect_to cashes_path, status: :see_other,
                notice: "The cash account was successfully destroyed." 
  end

  
private

  def set_cash
    @cash = Cash.eager_load(:account).where(id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@cash
  end

  def update_bank_params
    params.require(:cash).permit(:bank_name, :bank_addr, :account_name)
  end

  def create_bank_params
    params.require(:cash).permit(:bank_name, :bank_addr, :account_no, :account_name)
  end
end
