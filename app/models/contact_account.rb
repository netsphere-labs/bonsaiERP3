
# author: Boris Barroso
# email: boriscyber@gmail.com

# 取引先の口座. 口座なしも一つづつ作る. 自然に人名勘定になる。
class ContactAccount < ApplicationRecord  # Account から派生
  # 仮想的な親: 勘定科目
  include Accountable
  
  # 親
  belongs_to :contact

  #after_save :update_account_name
  
  before_validation :check
  
  validates_uniqueness_of :account_no, scope: :contact_id, allow_nil:true

  # form select で必要
  def account_id
    account.id
  end
  delegate :name, :currency, to: :account

  
private

=begin
  # for `after_save`
  # 二回保存を避けるため, 呼び出し側が account.save! すること
  def update_account_name
    ac_name = account.name.split('/', 2)
    account.name = contact.name + "/" + ac_name[ac_name[1].blank? ? 0 : 1]
  end
=end
  
  # for before_validation
  def check
    self.account_no = nil if account_no.blank?
  end
  
end
