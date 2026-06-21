require 'rails_helper'

RSpec.describe "curr_xchgs/new", type: :view do
  before(:each) do
    assign(:curr_xchg, CurrXchg.new())
  end

  it "renders new curr_xchg form" do
    render

    assert_select "form[action=?][method=?]", curr_xchgs_path, "post" do
    end
  end
end
