
# author: Boris Barroso
# email: boriscyber@gmail.com

# singular resource
# financial reports
class ReportsController < ApplicationController
  # form object @date_range
  include HaveDateRange
  before_action :set_date_range, only: [:show]


  # Profit and Loss (P/L) の表。横軸に月、縦に利益サマリ
  # -> これをグラフ化するのが dashboard#show
  def show
    @report = Report.new(@date_range)  #, tag_ids: @tag_ids)
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
