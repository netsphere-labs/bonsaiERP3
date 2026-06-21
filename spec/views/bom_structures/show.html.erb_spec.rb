require 'rails_helper'

RSpec.describe "bom_structures/show", type: :view do
  before(:each) do
    assign(:bom_structure, BomStructure.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
