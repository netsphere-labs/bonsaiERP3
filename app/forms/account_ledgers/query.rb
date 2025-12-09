
# author: Boris Barroso
# email: boriscyber@gmail.com

# 検索は, 1 取引年月日, 2 取引金額, 3 取引先名

# form object (search)
# 仕訳の検索は JeSearch
class AccountLedgers::Query < BaseForm
  attribute :text, :string

  # 取引年月日
  attribute :from, :date
  attribute :to, :date

  # 勘定科目は必須. 人名勘定なので, 取引先を兼ねる
  attribute :account_id, :integer

  attribute :amt_from, :bigint
  attribute :amt_to, :bigint
  
  attribute :state, array: true, default: ['approved']
  
  
  def search()
    raise ArgumentError, "勘定科目は必須" if account_id.blank?

    ret = AccountLedger.eager_load(:account)
                       .where(account_id: account_id) 
    ret = ret.where("reference ILIKE :s OR description ILIKE :s ", s: text) if !text.blank?
    ret = ret.where("date >= ?", from) if !from.blank?
    ret = ret.where("date <= ?", to) if !to.blank?
    # 金額
    ret = ret.where("amount >= ?", amt_from) if !amt_from.blank?
    ret = ret.where("amount <= ?", amt_to) if !amt_to.blank?
    
    return ret
  end

  
private

  def money(id)
    @rel.where(t[:account_id].eq(id).or(t[:account_to_id].eq(id)))
    .order('account_ledgers.date desc, account_ledgers.id desc')
    .includes(:contact, :account_to, :approver, :creator, :nuller, :updater)
  end

  def money_paged(id, page)
    money.page(page)
  end

  def payments(account_id)
    @rel.select(payment_columns(account_id).join(', '))
    .where('account_id=:id OR account_to_id=:id', id: account_id)
    .includes(:account, :account_to, :approver, :creator, :nuller, :updater)
  end

  def payments_ordered(account_id)
    payments(account_id).order('date desc, id desc')
  end

 

    def payment_columns(account_id)
      AccountLedger.column_names + ["account_id=#{account_id} AS is_account"]
    end

    #def t
    #  AccountLedger.arel_table
    #end
end
