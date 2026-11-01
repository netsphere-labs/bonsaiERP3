require 'rails_helper'

RSpec.describe "pur_item_prices/show", type: :view do
  before(:each) do
    assign(:pur_item_price, PurItemPrice.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
