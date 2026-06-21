require 'rails_helper'

RSpec.describe "curr_xchgs/show", type: :view do
  before(:each) do
    assign(:curr_xchg, CurrXchg.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
