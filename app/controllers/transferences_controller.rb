
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
      query = AccountLedger
    else
      @search = JeSearch.new( params.require(:je_search)
                                    .permit(*JeSearch.attribute_names) )
      query = @search.search()
    end
    @pagy, @journal_entries = pagy(:offset, query.order(:date, :entry_no, :id))
  end

  
  # GET /transferences?account_id
  def new
    # form object
    @journal_entry = Transference.new([])
    @journal_entry.date = Time.zone.now.to_date
  end

  
  def create
    # form object
    @journal_entry = Transference.new([])
    @journal_entry.assign transference_params, params.require(:entries),
                          current_organisation.currency

    begin
      ActiveRecord::Base.transaction do
        @journal_entry.assign_attributes entry_no: rand(2_000_000_000),
                                         operation: 'trans',
                                         status: 'approved'
        @journal_entry.save! current_user
      end
    rescue ActiveRecord::RecordInvalid
      render 'new', status: :unprocessable_entity
      return
    end
    
    redirect_to @journal_entry,
                notice: 'Se realizo correctamente la transferencia.'
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
    params.require(:transference).permit(:date, :reference )
  end
end
