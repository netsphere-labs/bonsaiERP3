require 'rails_helper'

RSpec.describe "curr_xchgs/index", type: :view do
  before(:each) do
    assign(:curr_xchgs, [
      CurrXchg.create!(),
      CurrXchg.create!()
    ])
  end

  it "renders a list of curr_xchgs" do
    render
    cell_selector = 'div>p'
  end
end
