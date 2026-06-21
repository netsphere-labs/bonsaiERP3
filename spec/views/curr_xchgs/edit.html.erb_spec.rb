require 'rails_helper'

RSpec.describe "curr_xchgs/edit", type: :view do
  let(:curr_xchg) {
    CurrXchg.create!()
  }

  before(:each) do
    assign(:curr_xchg, curr_xchg)
  end

  it "renders the edit curr_xchg form" do
    render

    assert_select "form[action=?][method=?]", curr_xchg_path(curr_xchg), "post" do
    end
  end
end
