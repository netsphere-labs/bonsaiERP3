
require 'rails_helper'

RSpec.describe ProdOrder, type: :model do
  it { should have_many(:accounts) }
  it { should have_many(:account_ledgers) }
end
