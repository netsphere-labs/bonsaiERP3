
# author: Boris Barroso
# email: boriscyber@gmail.com

# 振替伝票, 会計仕訳  -- Comprobantes de transferencia, asientos contables
class TransferencesController < ApplicationController
  before_action :set_journal_entry, only: %i[show edit update destroy]

  # 仕訳帳
  def index
    if params[:je_search].blank? || !params[:reset].blank?
      @search = JeSearch.new
      # Array of AccountLedger. 改ページは伝票単位ではない
      @journal_entries = AccountLedger
    else
      @search = JeSearch.new( params.require(:je_search)
                                .permit(*JeSearch.attribute_names) )
      @journal_entries = @search.search()
    end
    @journal_entries = @journal_entries.order(:date, :entry_no, :id)
                                       .page(params[:page])
  end

  
  # GET /transferences?account_id
  def new
    # form object
    @journal_entry = Transference.new(account_id: params[:account_id], date: Time.zone.now.to_date)
  end

  def create
    @journal_entry = Transference.new(transference_params)

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
    @journal_entry = Transference.new(
                        AccountLedger.where(entry_no: params[:entry_no]) )
  end

    def transference_params
      transference_attrs = params.require(:transference).permit(:account_to_id, :amount, :date, :exchange_rate, :reference, :verification)
      transference_attrs[:account_id] = @account.id
      transference_attrs
    end
end
