
# purchase invoice / sales invoice
class Invoice < ApplicationRecord
  belongs_to :partner, class_name: "Contact"

  # only pur-inv
  belongs_to :bp_bank_account, class_name: "ContactAccount", optional:true
  
  INV_TYPES = %w(sales purchase)
  
  STATUSES = %w(draft confirmed paied void).freeze
  enum :status, STATUSES.map{|x| [x,x]}.to_h

  ########################################
  # Validations
  
  validates_presence_of :date
  validates_presence_of :due_date
  
  validates_presence_of  :inv_type
  validates_inclusion_of :inv_type, in: INV_TYPES
  
  validates_lengths_from_database

  validates_presence_of :amount_total
  validates_presence_of :curr_code

end
