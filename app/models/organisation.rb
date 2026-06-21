
# author: Boris Barroso
# email: boriscyber@gmail.com

# 組織
# PostgreSQL スキーマと 1:1
class Organisation < ApplicationRecord

  DATA_PATH = "db/defaults"
  self.table_name = 'public.organisations'

  HEADER_CSS = %w(bonsai-header red-header blue-header white-header violet-header orange-header dark-header)

  ########################################
  #def settings
  #  self[:settings] ? JSON.parse(self[:settings]) : {}
  #end

  # PostgreSQL スキーマ分離
  # `Organisation` が保存された後に実行
  after_commit :on_after_create, on: :create
  
  ########################################
  # Relationships
  has_many :links, dependent: :destroy, autosave: true
  has_many  :master_links, -> { where(master_account: true, role: "admin") },
           class_name: "Link", foreign_key: :organisation_id
  has_one  :master_account, through: :master_link, source: :user

  has_many :users, through: :links, dependent: :destroy
  #has_many :active_users, -> { where('links.active = ?', true) }, through: :links, class_name: 'Link'

  ########################################
  # Validations
  
  validates_presence_of   :name

  # そのままドメイン名になるので, 英数のみ.
  validates :tenant, uniqueness: true, format: { with: /\A[a-z][a-z0-9]+\z/ },
                     length: { in: 3...15 }
if USE_SUBDOMAIN
  validate :valid_tenant_not_in_list
end

  before_validation :valid_header_css

  validates_email_format_of :email, if: -> { email.present? }, message: I18n.t('errors.messages.email')

  #with_options if: :persisted? do |val|
  validates_presence_of :country_code
  validates_presence_of :currency
    #val.validates_inclusion_of :currency, in: CURRENCIES.keys
  #validates_inclusion_of :country_code, in: COUNTRIES.keys
  #end

  ########################################
  # Delegations
  #delegate :name, :to_s, to: :currency_klass, prefix: 'currency'

  ########################################
  # Methods
  #def to_s
  #  name
  #end

  def active_users
    users.where('links.active = ?', true)
  end

  def build_master_account
    self.build_master_link.build_user
    self.master_link.creator = true
  end

  
  def country
    ISO3166::Country.new country_code
  end

  
  def create_organisation
    self.build_master_account
    user = master_link.user

    user.email = email
    user.password = password

    unless user.valid?
      set_user_errors(user)
      return false
    end

    self.save
  end

  def dued_on?
    Date.today > due_on
  rescue
    true
  end

  def dued_with_extension?
    Date.today > due_extension_date
  rescue
    true
  end

  def due_extension_date
    due_on + 4.days
  end

  def self.test_job(a = nil)
    f = File.new Rails.root.join('test_job.txt'), 'w+'
    f.write "This job was generated in #{Time.now} with a = #{a}"
    f.close
  end

  def header_css
    (settings && settings['header_css']) || 'bonsai-header'
  end

  # Especial method that deletes the schema, users and all related stuff
  def drop_related!
    ApplicationRecord.transaction do
      PgTools.drop_schema_if(tenant)
      User.where(id: links.map(&:user_id)).destroy_all
      self.destroy
    end
  end

  
private

    def set_user_errors(user)
      [:email, :password].each do |meth|
        user.errors[meth].each do |err|
          self.errors[meth] << err
        end
      end
    end

    # Sets the expiry date for the organisation until ew payment
    def set_due_date
      self.due_date = 30.days.from_now.to_date
    end

if USE_SUBDOMAIN    
  # For `validate()`
  def valid_tenant_not_in_list
    if INVALID_TENANTS.include?(tenant)
      errors.add :tenant, I18n.t('organisation.errors.tenant.list')
    end
  end
end

  # callback: `after_commit`
  # `Organisation` を作るだけで, 自動的にテナントの生成が走るっぽい.
  def on_after_create
    #puts "Here, creating tenant..."
    #Apartment::Tenant.create(self.tenant)
    #puts "Creating tenant was done!"
  end
  

    #def currency_klass
    #  @currency_klass ||= Currency.find(currency)
    #end

  # Sets or checks that the header_css is valid
  # for `before_validation()`  
  def valid_header_css
    self.settings = {} if !settings
    self.settings['header_css'] = 'bonsai-header'  if !HEADER_CSS.include?(header_css)
  end
end
