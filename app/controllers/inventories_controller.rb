
# author: Boris Barroso
# email: boriscyber@gmail.com

# 入出庫伝票
class InventoriesController < ApplicationController
  include Controllers::Print

  before_action :set_invt, only: %i[show]

  
  # GET /inventories
  def index
    if params[:date_range].blank? || !params[:reset].blank?
      @search = DateRange.new
      # ここは伝票単位ではなく, 明細単位
      @invts = InventoryDetail.joins(:inventory)
    else
      @search = DateRange.new( params.require(:date_range)
                                     .permit(*DateRange.attribute_names) )
      @invts = get_invt_details()
    end

    @invts = @invts.order('inventories.date, inventories.id, inventory_details.id')
                   .page(params[:page])
  end

  
  # GET /inventories/1
  def show
    respond_to do |format|
      format.html
      format.print
      #format.pdf { print_pdf 'show.print', "Inv-#{@inventory}" }
    end
  end

  
  # GET /inventories/1/show_movement
  def show_movement
    @inventory = present Inventory.includes(inventory_details: :item).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_movement.print', "Inv-#{@inventory}" }
    end
  end

  
  # GET /inventories/1/show_trans
  def show_trans
    @inventory = present Inventory.includes(inventory_details: :item).find(params[:id])

    respond_to do |format|
      format.html
      format.print
      format.pdf { print_pdf 'show_trans.print', "Inv-#{@inventory}" }
    end
  end

  
private

  def set_invt
    # ここは伝票
    @invt = Inventory.eager_load(:details).find(params[:id])
  end


  def get_invt_details
    ret = InventoryDetail.joins(:inventory)
    ret = ret.where('inventories.date >= ?', @search.date_start) if !@search.date_start.blank?
    ret = ret.where('inventories.date <= ?', @search.date_end) if !@search.date_end.blank?

    ret = ret.where('inventory_details.item_id = ?', @search.item_id) if !@search.item_id.blank?
    ret = ret.where('inventories.store_id = ?', @search.store_id) if !@search.store_id.blank?
    
    return ret
  end

  
    def set_date_range
      if params[:date_start].present? && params[:date_end].present?
        @date_range = DateRange.parse(params[:date_start], params[:date_end])
      else
        @date_range = DateRange.default
      end
    end
end
