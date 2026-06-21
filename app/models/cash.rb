
# author: Boris Barroso
# email: boriscyber@gmail.com

# 自社の銀行口座・現金マスタ
class Cash < ApplicationRecord # Account から派生
  # 仮想的な親: 勘定科目
  include Accountable

  # たまたま別銀行で口座番号が一致する、のは考えない
  validates :account_no, uniqueness: true, allow_nil: true #{scope: :bank_name}
  
  before_validation :check_account_no
  
=begin
  # can't use Bank.stored_attributes methods[:extras]
  alias_method :old_attributes, :attributes
  def attributes
    old_attributes.merge(
      Hash[EXTRA_COLUMNS.map { |k| [k.to_s, send(k)] }]
    )
  end
=end
  
  # Related methods for money accounts
  include Models::Money

  def to_s
    account.name
  end

  def pendent_ledgers_tag
    # 内容不明
  end

  
private
  # before_validation
  def check_account_no
    self.bank_name  = nil if self.bank_name.blank?
    self.account_no = nil if self.account_no.blank? 
  end

    def set_defaults
      self.total_amount ||= 0.0
    end
end
