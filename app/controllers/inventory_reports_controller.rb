
# author: Boris Barroso
# email: boriscyber@gmail.com

# singular resource
class InventoryReportsController < ApplicationController
  before_action :set_date_range, only: [:show]


  # リポートを一覧表示
  def show
  end
  
  # 
  def inventory
    @report = InventoryReportService.new(inventory_params)
    @tag_group = TagGroup.api
  end


  # GET
  # demand and supply schedule
  def schedule
    @date = Date.today - 1
    
    # only committed demand
    @demand_skd = MovementDetail.joins(:order)
                    .where('orders.type = ? AND ship_date > ? AND state = ?', 'SalesOrder', @date, 'confirmed')
                    .group('ship_date, item_id').select('SUM(quantity) AS quantity')
                    .order('ship_date')
    @supply_skd = MovementDetail.joins(:order)
                    .where('orders.type = ? AND delivery_date > ? AND state = ?', 'PurchaseOrder', @date, 'confirmed')
                    .group('delivery_date, item_id').select('SUM(quantity) AS quantity')
                    .order('delivery_date')
  end
  
  
private

  # for `before_action`
  def set_date_range
    if params[:date_range].blank? || !params[:reset].blank?
      today = Date.today
      # `DateRange` is a form object.
      @date_range = DateRange.new date_start: today - 366, date_end: today,
                                  time_strata: 'month'
    else
      @date_range = DateRange.new params.require(:date_range)
                                        .permit(*DateRange.attribute_names)
    end
  end

    def set_tag_ids
      @tag_ids = Tag.select("id").where(id: params[:tags]).pluck(:id).uniq
    end

    def inventory_params
      {
        type: params[:type] || 'Income',
        date_field: params[:date_field] || 'date',
        date_start: @date_range.date_start.to_s,
        date_end: @date_range.date_end.to_s,
        state: params[:state] || 'approved',
        tag_group_id: params[:tag_group_id]
      }
    end
end
