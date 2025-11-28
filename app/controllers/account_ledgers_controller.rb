
# author: Boris Barroso
# email: boriscyber@gmail.com

# general ledger
class AccountLedgersController < ApplicationController
  include Controllers::Print

  before_action :set_je, only: [:update, :destroy, :conciliate, :null]

  
  # GET /account_ledger
  def show
    if params[:account_ledgers_query].blank? #|| !params[:reset].blank?
      @search = AccountLedgers::Query.new
      #@ledgers = AccountLedger    nothing
    else
      @search = AccountLedgers::Query.new(
                        params.require(:account_ledgers_query)
                              .permit(*AccountLedgers::Query.attribute_names) )
      @ledgers = @search.search()
                   .eager_load(:creator, :updater, :approver, :nuller)
                   .order(:date, :entry_no, :id).page(params[:page])
    end
  end


=begin
  # GET /account_ledgers/:id
  def show
    #@ledgers = AccountLedger.find(params[:id])

    respond_to do |format|
      format.html
      format.print
      #format.pdf { print_pdf 'show.print', "recibo-#{@ledger}"  unless params[:debug] }
    end
  end
=end

  
  # PATCH /account_ledgers/:id
  # update the reference
  def update
    authorize @je
    
    @je.assign account_ledger_params
    begin
      ActiveRecord::Base.transaction do
        @je.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :edit, status: :unprocessable_entity
      return
    end
    
    redirect_to({action:"show", date: @je.date, entry_no: @je.entry_no})
  end

  
  # PATCH /account_ledgers/:id/conciliate
  def conciliate
    @conciliate = ConciliateAccount.new(@account_ledger)

    # TODO: Move the logic and control from the model or service
    if @conciliate.conciliate!
      flash[:notice] = 'Se ha verificado la transacción correctamente.'
    else
      flash[:error] = 'No es posible verificar la transacción, quiza fue verificada o anulada'
    end

    redirect_to account_ledger_path(@account_ledger.id)
  end

  
  # PATCH /account_ledgers/:id/null
  def null
    @null = NullAccountLedger.new(@account_ledger)

    if @null.null!
      flash[:notice] = 'Se ha anulado correctamente la transacción.'
    else
      flash[:error] = 'No fue posible anular la transacción, quiza ya fue verificada o anulada.'
    end

    redirect_to account_ledger_path(@account_ledger.id)
  end


  def destroy
    authorize @je
    # TODO: impl.
  end
  

private

  def set_je
    @je = JournalEntry.new( 
            # multi lines
            AccountLedger.where(date: params[:date], entry_no: params[:entry_no]) )
    raise ActiveRecord::RecordNotFound if @je.lines.empty?
  end

    def account_ledger_params
      params.permit(:reference)
    end
end
