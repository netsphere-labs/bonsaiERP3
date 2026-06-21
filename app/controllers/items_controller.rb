
# author: Boris Barroso
# email: boriscyber@gmail.com

# Product/Item Master
class ItemsController < ApplicationController
  include Controllers::TagSearch

  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  def index
    if params[:item_search].blank? || !params[:reset].blank?
      @search = ItemSearch.new
    else
      @search = ItemSearch.new params.require(:item_search)
                                     .permit(*ItemSearch.attribute_names)
    end

    @pagy, @items = pagy(:offset, @search.search_by_text().order('items.name ASC'))
  end

  
  # Search for income items
  # GET /items/search_income?term=:term
  def search_income
    @items = Item.income.search(params[:term]).limit(20)

    render json: ItemSerializer.new.income(@items)
  end

  # Search for expense items
  # GET /items/search_expense?term=:term
  def search_expense
    @items = Item.active.search(params[:term]).limit(20)

    render json: ItemSerializer.new.expense(@items)
  end

  # GET /items/:store_id/search_inventory
  def search_inventory
    @items = Item.active.search(params[:term]).limit(20)

    render json: ItemSerializer.new.inventory(@items, params[:id])
  end

  # GET /items/1 show action

  # GET /items/new
  def new
    @item = Item.new(new_attrs)
  end

  # GET /items/1/edit
  def edit
  end

  
  # POST /items
  def create
    @item = Item.new(item_params)
    @item.creator_id = current_user.id
    
    begin
      ActiveRecord::Base.transaction do
        @item.save!
        @item.histories.create!(user_id: current_user.id,
                                new_item:true,
                                history_data: {})
      end
    rescue ActiveRecord::RecordInvalid
      render 'new', status: :unprocessable_entity
      return
    end
    
    redirect_to @item
  end

  
  # PUT /items/1
  def update
    if @item.update(item_params)
      flash[:notice] = "Se actualizo correctamente el ítem."
      redirect_ajax @item
    else
      render :edit
    end
  end

  # DELETE /items/1
  def destroy
    @item.destroy

    redirect_ajax @item
  end

  
private

  def set_item
    @item = Item.find(params[:id])
  end
  

  def item_params
    params.require(:item).permit(:code, :name, :active, :stockable,
                        :for_sale, :price, :buy_price, :unit_id, :description,
                        :accounting_id)
  end

    def render_or_redirect_item
      if request.xhr?
        if params[:for_sale] == 'true'
          render json: ItemSerializer.new.income([@item]).first
        else
          render json: ItemSerializer.new.expense([@item]).first
        end
      else
        redirect_to @item, notice: 'Se ha creado el ítem correctamente.'
      end
    end

    def new_attrs
      if params[:for_sale] === 'false'
        {for_sale: false}
      else
        {}
      end
    end
end
