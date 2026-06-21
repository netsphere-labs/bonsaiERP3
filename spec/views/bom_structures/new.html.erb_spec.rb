require 'rails_helper'

RSpec.describe "bom_structures/new", type: :view do
  before(:each) do
    assign(:bom_structure, BomStructure.new())
  end

  it "renders new bom_structure form" do
    render

    assert_select "form[action=?][method=?]", bom_structures_path, "post" do
    end
  end
end
