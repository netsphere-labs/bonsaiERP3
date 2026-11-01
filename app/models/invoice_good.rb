
class InvoiceGood < ApplicationRecord
  belongs_to :invoice

  belongs_to :item
  validates_presence_of :qty
  validates_presence_of :txn_amount
end
