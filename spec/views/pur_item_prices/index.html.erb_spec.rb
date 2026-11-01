require 'rails_helper'

RSpec.describe "pur_item_prices/index", type: :view do
  before(:each) do
    assign(:pur_item_prices, [
      PurItemPrice.create!(),
      PurItemPrice.create!()
    ])
  end

  it "renders a list of pur_item_prices" do
    render
    cell_selector = 'div>p'
  end
end
