require 'rails_helper'

RSpec.describe "currencies/index", type: :view do
  before(:each) do
    assign(:currencies, [
      Currency.create!(),
      Currency.create!()
    ])
  end

  it "renders a list of currencies" do
    render
    cell_selector = 'div>p'
  end
end
