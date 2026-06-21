
# author: Boris Barroso
# email: boriscyber@gmail.com

# 取引先. 人名勘定
class PartnersController < ApplicationController
  include Controllers::TagSearch
  
  before_action :set_partner,
                only: [:show, :edit, :update, :destroy, :incomes, :expenses]

  # GET /contacts
  def index
    @search_term = !params[:search].blank? ? params[:search] : nil
    
    if @search_term
      @pagy, @partners = pagy(:offset, Contact.search(@search_term))
    else
      @pagy, @partners = pagy(:offset, Contact.order('matchcode asc'))
    end

    #@contacts = @contacts.any_tags(*tag_ids)  if tag_ids
  end

  
  # GET /contacts/1
  def show
    params[:operation] ||= 'all'
  end

  # GET /contacts/new
  def new
    @partner = Contact.new
    #@contact_account = ContactAccount.new account: Account.new(currency:"JPY", active:true, subtype:'APAR')
  end

  # GET /contacts/1/edit
  def edit
  end
  
  # POST /contacts
  def create
    @partner = Contact.new(contact_params)
    # copy from `contact_accounts/create`
    #@contact_account =
    #  ContactAccount.new account: Account.new(params.require(:contact)
    #                        .require(:contact_account).require(:account)
    #                        .permit(:name, :currency, :active, :description))
    #@contact_account.assign_attributes contact_account_params
    #@contact_account.account.subtype = 'APAR'

    begin
      ActiveRecord::Base.transaction do
        @partner.save! 
        #@contact_account.contact_id = @partner.id
        # save! だけだと account が作られない
        #@contact_account.save!
        #@contact_account.account.accountable = @contact_account
        #@contact_account.account.creator_id = current_user.id
        #@contact_account.account.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity 
      return
    end
    
    redirect_to({action:"show", id: @partner},
                notice: 'Se ha creado el contacto.')
  end

  
  # PUT /contacts/1
  def update
    @partner.assign_attributes(contact_params)
    if @partner.save
      redirect_to partner_path(@partner.id)
    else
      render :edit, status: :unprocessable_entity 
    end
  end

  
  # DELETE /contacts/1
  def destroy
    @partner.destroy!

    if @contact.destroyed?
      flash[:notice] = 'El contacto fue eliminado'
    else
      flash[:error] = 'No fue posible eliminar el contacto'
    end

    redirect_to contacts_path, status: :see_other
  end


  # GET /contacts/:id/expenses
  def expenses
    params[:page_expenses] ||= 1
  end

  # GET /contacts/:id/incomes
  def incomes
    params[:page_incomes] ||= 1
  end
  
  
private

  #def contact_account_params
  #  params.require(:contact).require(:contact_account)
  #        .permit(:bank_name, :bank_addr, :account_no, :account_name)
  #end

  def set_partner
    @partner = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:matchcode, :name, :email, :phone, :mobile,
                        :tax_number, :address, :client, :supplier, :staff, :country_code)
  end


    def export_contacts
      send_data StringEncoder.encode("UTF-8", "ISO-8859-1", generate_csv("\t") ), filename: "contactos-p#{@page}.xls"
    end

    def generate_csv(col_sep = ',')
      require 'csv'

      CSV.generate(col_sep: col_sep) do |csv|
        csv << csv_header
        @contacts.per(200).find_each do |cont|
          csv << [cont.matchcode, cont.email, cont.phone, cont.mobile, cont.address]
        end
      end
    end

    def csv_header
      %w(Name Email Phone Mobile Address)
    end
end
