
# order
class TransferRequest < Order
  # from, required
  belongs_to :store

  # to, required
  belongs_to :trans_to, class_name: "Store"
  #validates_presence_of :trans_to_id

  validate :check

private
  
  # for `validate`
  def check
    if store_id == trans_to_id
      errors.add :trans_to_id, "cannot be the same as the source"
    end
  end
end
