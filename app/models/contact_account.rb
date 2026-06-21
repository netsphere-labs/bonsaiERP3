
# author: Boris Barroso
# email: boriscyber@gmail.com

# 取引先の bank account. 
class ContactAccount < ApplicationRecord 
  
  # 親
  belongs_to :contact

  # bank name, branch name
  validates_presence_of :bank_name
  
  validates_presence_of :account_no, :account_name
  validates_uniqueness_of :account_no #, scope: :contact_id, allow_nil:true
  
  before_validation :check

=begin
  # form select で必要
  def account_id
    account.id
  end
  delegate :name, :currency, to: :account
=end

  def long_name
    "#{bank_name} #{account_no} #{account_name}"
  end
  
private

=begin
  # for `after_save`
  # 二回保存を避けるため, 呼び出し側が account.save! すること
  def update_account_name
    ac_name = account.name.split('/', 2)
    account.name = contact.name + "/" + ac_name[ac_name[1].blank? ? 0 : 1]
  end
=end
  
  # for `before_validation()`
  def check
    self.account_no = nil if account_no.blank?
  end
  
end
