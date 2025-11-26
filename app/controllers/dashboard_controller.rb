
# author: Boris Barroso
# email: boriscyber@gmail.com

class DashboardController < ApplicationController
  skip_before_action :check_authorization!, only: [:home]

  # form object @date_range
  include HaveDateRange
  before_action :set_date_range, only: [:show]


  # GET /home
  def home
    #render template: 'dashboard/home'
  end

  
  # GET /dashboard
  # 累積 P/L のチャート. 表は reports#show
  def show
    @report = Report.new @date_range
  end

end
