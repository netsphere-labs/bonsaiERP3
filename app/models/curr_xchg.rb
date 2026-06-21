
# currency rates
class CurrXchg < ApplicationRecord
  BASE_CURR = "USD"

  def self.convert(from_amt, to_curr, date)
    raise TypeError if !from_amt.is_a?(Money)
    raise TypeError if !to_curr.is_a?(Money::Currency)
    raise TypeError if !date.is_a?(Date)

    # #amount => "123.45"  #cents => "12345"
    return from_amt.cents *
           get_rate(from_amt.currency.iso_code, to_curr.iso_code, date) *
           (10 ** (to_curr.exponent - from_amt.currency.exponent))
  end

  
  # @return 為替レートマスタが登録されていない場合は, nil を返す
  def self.get_rate(from_curr, to_curr, date)
    raise TypeError if !from_curr.is_a?(String)
    from_curr = from_curr.upcase
    raise TypeError if !to_curr.is_a?(String)
    to_curr = to_curr.upcase
    
    from_rate = from_curr == CurrXchg::BASE_CURR ? 1.0 :
                  (CurrXchg.where('date >= ? AND curr_code = ?', date, from_curr).order("date ASC").limit(1).take &.rate)
    to_rate =  to_curr == CurrXchg::BASE_CURR ? 1.0 :
                 (CurrXchg.where('date >= ? AND curr_code = ?', date, to_curr).order("date ASC").limit(1).take &.rate)

    return nil if from_rate.nil? || to_rate.nil?
    return BigDecimal("1.0") * to_rate / from_rate
  end
                    
end
