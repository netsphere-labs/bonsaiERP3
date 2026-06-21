
# author: Boris Barroso
# email: boriscyber@gmail.com

# 組織. テナントと 1:1
class OrganisationsController < ApplicationController
  before_action :redirect_app_domain
  
  # `current_user` がテナントのアクセス権を持っているかどうか
  skip_before_action :check_authorization!, only: [:index, :new, :create]

  before_action :check_user_master_account, except: [:index, :new, :create]

  before_action :set_org, only: %i[show edit update ]

  
  def index
    # TODO: superuser の場合は, 全部を表示
    @organisations = Organisation.joins(:links)
                       .where('user_id = ? AND links.active = TRUE',
                              current_user.id)
  end

  
  # GET /organisations/new
  def new
  end

  
  def create
  end


  def show
  end


  def edit
  end

  
  # POST /organisations
  def update
    current_organisation.attributes = organisation_params

    tenant = TenantCreator.new(@organisation) # Should be background process

    if current_organisation.save && tenant.create_tenant
      session[:organisation] = {id: current_organisation.id}
      flash[:notice] = "Se ha creado su empresa correctamente."
      #job = QU.enqueue CreateTenant, @organisation.id, session[:user_id]

      redirect_to dashboard_path
    else
      render :new
    end
  end

  
private

  def set_org
    @org = Organisation.find params[:id]
  end

  # for `before_action`
  def redirect_app_domain
if USE_SUBDOMAIN
    if request.host != "app.#{DOMAIN}"      
      redirect_to organisations_url(subdomain:"app"), allow_other_host:true
    end
end
  end

=begin
    def check_tenant_creation
      unless current_organisation
        redirect_to new_registration_path, alert: "Debe confirmar su registro o registrarse." and return
      end

      if current_tenant && PgTools.schema_exists?(current_organisation.tenant)
        redirect_to  dashboard_url(host: request.domain, subdomain: org.tenant, auth_token: user.auth_token) and return
      end
    end
=end
  
    def organisation_params
      params.require(:organisation).permit(:name, :currency, :country_code,
                                          :time_zone,:phone, :mobile, :email,
                                          :address)
    end

    def check_user_master_account
      unless user_with_role.master_account?
        redirect_to sessions_url(subdomain: false) and return
      end
    end
end
