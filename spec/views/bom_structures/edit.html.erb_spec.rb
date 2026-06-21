require 'rails_helper'

RSpec.describe "bom_structures/edit", type: :view do
  let(:bom_structure) {
    BomStructure.create!()
  }

  before(:each) do
    assign(:bom_structure, bom_structure)
  end

  it "renders the edit bom_structure form" do
    render

    assert_select "form[action=?][method=?]", bom_structure_path(bom_structure), "post" do
    end
  end
end
