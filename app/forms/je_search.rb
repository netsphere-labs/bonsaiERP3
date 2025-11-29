
class JeSearch < BaseForm
  attribute :from, :date
  attribute :to, :date

  # @return [Array of AccountLedger] 伝票ではない
  def search
    ret = AccountLedger
    ret = ret.where('date >= ?', from) if !from.blank?
    ret = ret.where('date <= ?', to) if !to.blank?

    return ret
  end
  
end
