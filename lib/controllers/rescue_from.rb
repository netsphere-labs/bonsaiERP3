
# See active_support/rescuable


module Controllers::RescueFrom

  def self.included(base)
    base.instance_eval do
      rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
      rescue_from ActionController::RoutingError, with: :render_not_found
    end
  end


private

  def render_record_not_found
    # development環境だと, ここに到達するが, レンダリング結果は捨てられる (debug screen)
    render template: 'errors/record_not_found', status: 404
  end

    def render_not_found
      render template: 'errors/not_found', status: 404
    end

    def render_error
      render template: 'errors/500', status: 500
    end
end
