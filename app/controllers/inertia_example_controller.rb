# frozen_string_literal: true

class InertiaExampleController < InertiaController
  skip_before_action :require_login

  def index
    @page_title = "demo"
    
    render inertia: {
      rails_version: Rails.version,
      ruby_version: RUBY_DESCRIPTION,
      rack_version: Rack.release,
      inertia_rails_version: InertiaRails::VERSION,
    }
  end
end
