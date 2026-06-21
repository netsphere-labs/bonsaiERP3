require 'rails_helper'

RSpec.describe "invoices/edit", type: :view do
  let(:invoice) {
    Invoice.create!()
  }

  before(:each) do
    assign(:invoice, invoice)
  end

  it "renders the edit invoice form" do
    render

    assert_select "form[action=?][method=?]", invoice_path(invoice), "post" do
    end
  end
end
