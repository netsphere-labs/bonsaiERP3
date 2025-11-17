
# author: Boris Barroso
# email: boriscyber@gmail.com

# 振替伝票, 会計仕訳  -- Comprobantes de transferencia, asientos contables
class TransferencesController < ApplicationController
  before_action :set_journal_entry, only: %i[show edit update destroy]

  
  # GET /transferences?account_id
  def new
    @transference = Transference.new(account_id: params[:account_id], date: Time.zone.now.to_date)
  end

  def create
    @transference = Transference.new(transference_params)

    if @transference.transfer
      redirect_to @transference.account, notice: 'Se realizo correctamente la transferencia.'
    else
      render 'new'
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

  
private

  def set_journal_entry
    # form object
    @journal_entry = Transference.new AccountLedger.where(entry_id: params[:entry_id])

      unless @account
        redirect_back(fallback_location: root_path, alert: 'Debe seleccionar una cuenta activa')
      end
    end

    def transference_params
      transference_attrs = params.require(:transference).permit(:account_to_id, :amount, :date, :exchange_rate, :reference, :verification)
      transference_attrs[:account_id] = @account.id
      transference_attrs
    end
end
