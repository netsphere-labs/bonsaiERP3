require 'rails_helper'

RSpec.describe "currencies/edit", type: :view do
  let(:currency) {
    Currency.create!()
  }

  before(:each) do
    assign(:currency, currency)
  end

  it "renders the edit currency form" do
    render

    assert_select "form[action=?][method=?]", currency_path(currency), "post" do
    end
  end
end
