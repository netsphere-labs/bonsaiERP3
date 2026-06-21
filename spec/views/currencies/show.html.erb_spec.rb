require 'rails_helper'

RSpec.describe "currencies/show", type: :view do
  before(:each) do
    assign(:currency, Currency.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
