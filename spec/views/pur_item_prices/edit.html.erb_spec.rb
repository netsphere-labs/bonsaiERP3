require 'rails_helper'

RSpec.describe "pur_item_prices/edit", type: :view do
  let(:pur_item_price) {
    PurItemPrice.create!()
  }

  before(:each) do
    assign(:pur_item_price, pur_item_price)
  end

  it "renders the edit pur_item_price form" do
    render

    assert_select "form[action=?][method=?]", pur_item_price_path(pur_item_price), "post" do
    end
  end
end
