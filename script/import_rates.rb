
# import currency rates

ENV["RAILS_ENV"] = "development" if !ENV["RAILS_ENV"]
require_relative "../config/environment" unless defined?(RAILS_ROOT)

require 'json'

def import_rates fname
  json = JSON.parse(File.read(fname))
  puts json
  raise "internal error, " + json["base"] if json["base"] != CurrXchg::BASE_CURR

  date = Date.today
  
  json["rates"].each do |k, f|
    next if !Money::Currency.find(k)
    CurrXchg.create!(curr_code: k.upcase, date: date, rate: f)
  end
end

import_rates "../db/fx_rates/2025-07-16"


