
# monkey patch for `Money::Currency`

class Money
  class Currency
    module Loader

      class << self
        # "JPY" が2つ定義されており、:iso_code がユニークではない。
        #   -> unregister() で削除できない. reset!() で再読み込みされる。
        # 大元の loader を修正する
        def load_currencies()
          currencies = parse_currency_file("currency_iso.json")
          currencies.merge! parse_currency_file("currency_non_iso.json")
          #currencies.merge! parse_currency_file("currency_backwards_compatible.json")
        end
      end
    end
  end
end

