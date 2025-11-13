
# author: Boris Barroso
# email: boriscyber@gmail.com

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout lambda { |c|
    case
    when (c.request.xhr? or params[:xhr]) then false
    when params[:print].present?          then 'print'
    else
     'application'
    end
  }

  include Pundit::Authorization
  
  include Controllers::Authorization
  include Controllers::RescueFrom

  protect_from_forgery with: :exception

  
  ########################################
  # Callbacks

  # Sorcery core module
  # ポカ避けのため、ログイン不要なコントローラで `skip_before_action` すること.
  # 未ログインのときは `not_authenticated()`
  before_action :require_login
  
  before_action :set_organisation_session # Must go before :check_authorization!
  before_action :set_page

  # `current_user` がテナントのアクセス権を持っているかどうか
  # サブクラスで不要な場合は, `skip_before_action` すること.
  before_action :check_authorization!
  
  before_action :set_locale, if: :current_user

  # especial redirect for ajax requests
  def redirect_ajax(klass, options = {})
    if request.xhr?
      serialized_xhr_response klass, options
    else
      url = options[:url] || klass

      if request.delete?
        set_redirect_options(klass, options)
        url = "/#{klass.class.to_s.downcase.pluralize}" unless url.is_a?(String)
      end

      redirect_to url
    end
  end

=begin
  # Add some helper methods to the controllers
  def help
    Helper.instance
  end
=end
  
  # @return [Organisation | nil] 組織
  def current_organisation
    # つど確認が必要
if USE_SUBDOMAIN
    return Organisation.find_by(tenant: Apartment::Tenant.current)
else
    return Organisation.first
end
  end
  helper_method :current_organisation

=begin
  def current_link
    @link ||= current_user.links.org_links(current_organisation.id).first!
  end
  helper_method :current_link
=end
  
  def user_with_role
    @user_with_role ||= Link.where(organisation_id: current_organisation.id,
                                   user_id: current_user.id).take
  end
  helper_method :user_with_role

  
  def path_sub(path, extras = {})
    if USE_SUBDOMAIN
      send(path, {host: DOMAIN, subdomain: session[:tenant]}.merge(extras))
    else
      extras.delete(:subdomain)
      send(path, extras)
    end
  end

  
private

  # Sorcery: 未ログインの状態で要ログインのページにアクセスした時に呼び出される
  def not_authenticated
    flash[:alert] = "ログインしてください。"
    redirect_to new_user_session_url(subdomain:"app"), allow_other_host:true 
  end

  
    # Creates the flash messages when an item is deleted
    def set_redirect_options(klass, options)
      if klass.destroyed?
        case
        when (options[:notice].blank? and flash[:notice].blank?)
          flash[:notice] = "Se ha eliminado el registro correctamente."
        when (options[:notice] and flash[:notice].blank?)
          flash[:notice] = options[:notice]
        end
      else
        if flash[:error].blank? and klass.errors.any?
          txt = options[:error] ? options[:error] : "No se pudo borrar el registro: #{klass.errors[:base].join(", ")}."
          flash[:error] = txt
        elsif flash[:error].blank?
          txt = options[:error] ? options[:error] : "No se pudo borrar el registro."
          flash[:error] = txt
        end
      end
    end

    delegate :name, :currency, to: :current_organisation, prefix: :organisation, allow_nil: true
    alias_method :currency, :organisation_currency
    helper_method :currency, :organisation_name

    def set_page
      @page = params[:page] || 1
    end


     # Checks if is set the organisation session
    def organisation?
      current_organisation.present?
    end
    helper_method :organisation?

  
    def set_organisation_session
      if current_organisation
        OrganisationSession.organisation = current_organisation
      end
    end

    def search_term
      params[:search] || params[:q] || params[:term]
    end

    def serialized_xhr_response(klass, options)
      r = ControllerServiceSerializer.new(klass)
      options.merge(methods: [:destroyed?])  if request.delete?

      render json: r.to_json(only: options[:only], except: options[:except], methods: options[:methods])
    end

    def set_locale
      I18n.locale = current_user.locale || :es
    end

end

class MasterAccountError < StandardError; end
