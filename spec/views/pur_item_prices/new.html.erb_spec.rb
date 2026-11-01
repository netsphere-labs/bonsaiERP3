require 'rails_helper'

RSpec.describe "pur_item_prices/new", type: :view do
  before(:each) do
    assign(:pur_item_price, PurItemPrice.new())
  end

  it "renders new pur_item_price form" do
    render

    assert_select "form[action=?][method=?]", pur_item_prices_path, "post" do
    end
  end
end
