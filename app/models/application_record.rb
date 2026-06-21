

class ApplicationRecord < ActiveRecord::Base
  # primary データベース
  primary_abstract_class
end


#################################################################
# 共通ルーチン

# 10^exp 倍して四捨五入
# @param real [String]  the `<input>` value
def nominal_amount real, curr_code
  raise TypeError if curr_code && !curr_code.is_a?(String)

  return 0 if real.blank?
  
  exp = curr_code.blank? ? 0 : Money::Currency.find(curr_code).exponent
  return (BigDecimal(real) * (10 ** exp)).round(0, BigDecimal::ROUND_HALF_UP)
end
