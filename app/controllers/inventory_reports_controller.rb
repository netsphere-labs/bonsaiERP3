
# author: Boris Barroso
# email: boriscyber@gmail.com

# singular resource
class InventoryReportsController < ApplicationController
  # form object @date_range
  include HaveDateRange
  before_action :set_date_range, only: [:show, :schedule]

  
  # 数量ベースの表
  def show
    @report = InventoryReportService.new(inventory_params)
  end
  

  # GET
  # demand and supply schedule
  # 特定の品目なら数量でいいけど, 会社全体のときは??
  def schedule
    @date = Time.zone.today - 1
    
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
