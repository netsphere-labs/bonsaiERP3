
# order
class TransferRequest < Order
  belongs_to :trans_to, class_name: "Store"
  #validates_presence_of :trans_to_id
end
