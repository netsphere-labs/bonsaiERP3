
# author: Boris Barroso
# email: boriscyber@gmail.com

# Business Partner. 法人も個人も
class Contact < ApplicationRecord

  include Models::Tag

  before_destroy :check_relations

  ########################################
  # Relationships

  # bank accounts.
  has_many :contact_accounts

  has_many :incomes, -> { where(type: 'Income').order('accounts.date desc, accounts.id desc') },
           foreign_key: :contact_id

  has_many :expenses, -> { where(type: 'Expense').order('accounts.date desc, accounts.id desc') },
           foreign_key: :contact_id

  has_many :inventories

  ########################################
  # Validations

  validates_presence_of :country_code
  validates :tax_number, uniqueness: {scope: :country_code}, allow_nil: true
  
  before_validation :norm
  validate :check
  
  validates :matchcode, presence: true, uniqueness: true #{ scope: :type }
  validates :name, presence: true
  
  # `localhost` が通らない。これはダメだ.
  #validates_email_format_of :email, allow_blank: true,
  #  message: I18n.t('errors.messages.invalid_email_format')

  validates_lengths_from_database

  ########################################
  # Scopes
  scope :clients, -> { where(client: true) }
  scope :suppliers, -> { where(supplier: true) }

  def self.search search_term
    # `ILIKE` は PostgreSQL 拡張.
    sql = %w(matchcode name email phone mobile).map {|field| "contacts.#{field} ILIKE :s" }
    where(sql.join(' OR ' ), s: "%#{search_term}%")
  end

  delegate :total_in, :total_out, to: :calculation

  ########################################
  # Methods

  # Finds a contact using the type
  # @param String
  def self.find_with_type(type)
    type = 'all' unless TYPES.include?(type)
    case type
    when 'Client' then Contact.clients
    when 'Supplier' then Contact.suppliers
    when 'All' then Contact.scoped
    end
  end

  def to_s
    matchcode
  end

  def to_param
    "#{id}-#{to_s}".parameterize
  end

  def account_cur(cur)
    accounts.where(currency: cur).first
  end

  def complete_name
    "#{first_name} #{last_name}"
  end
  alias_method :pdf_name, :complete_name

  # Creates an instance of an account with the defined currency
  def set_account_currency(cur)
    accounts.build(name: to_s, currency: cur, amount: 0)
  end

  def incomes_expenses_status
    { id: id, incomes: incomes_status, expenses: expenses_status }
  end

  
  # 取引先との取引の一覧
  def op_list op
    raise ArgumentError if ![:all, :sales, :purchase].include?(op)

    # STI にしているのが効く. TODO: filter
    return Order.where(contact_id: self.id)
  end
  
  def total_incomes
    incomes.active
    .sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
  end

  def total_expenses
    expenses.active
    .sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
  end

  
private

  # for `before_validation`
  def norm
    self.matchcode = matchcode.to_s.unicode_normalize(:nfkc).strip.upcase
    self.tax_number = nil if tax_number.blank?
  end

  # for `validate()`
  def check
    if !staff && !client && !supplier
      errors.add :base, "must enable at least one of staff, client, supplier"
    end
  end
  
    # Check if the contact has any relations before destroy
    def check_relations
      accounts.empty? && inventories.empty?
    end

    def calculation
      @calculation ||= Contacts::Calculation.new(self)
    end
end
