
# 元帳の検索は AccountLedgers::Query
class JeSearch < BaseForm
  attribute :from, :date
  attribute :to, :date

  # 勘定科目・取引先。optional
  attribute :account_id, :integer

  # form 側は小数点あり
  attribute :amt_from, :decimal
  attribute :amt_to, :decimal

  
  # @return [Array of AccountLedger] 伝票ではない
  def search
    ret = AccountLedger

    if !account_id.blank?
      ret = ret.where(account_id: account_id)
    end
    
    ret = ret.where('date >= ?', from) if !from.blank?
    ret = ret.where('date <= ?', to) if !to.blank?

    # 金額
    ret = ret.where("amount >= ?", amt_from) if !amt_from.blank?
    ret = ret.where("amount <= ?", amt_to) if !amt_to.blank?

    return ret
  end
  
end
