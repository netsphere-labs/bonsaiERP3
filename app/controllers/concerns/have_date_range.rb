
module HaveDateRange
  extended ActiveSupport::Concern

  # for `before_action`
  def set_date_range
    if params[:date_range].blank? || !params[:reset].blank?
      today = Time.zone.today
      # `DateRange` is a form object.
      @date_range = DateRange.new date_start: today - 366, date_end: today,
                                  time_strata: 'month'
    else
      @date_range = DateRange.new params.require(:date_range)
                                        .permit(*DateRange.attribute_names)
    end
  end
  
end
