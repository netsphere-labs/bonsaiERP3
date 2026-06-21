require 'rails_helper'

RSpec.describe "bom_structures/index", type: :view do
  before(:each) do
    assign(:bom_structures, [
      BomStructure.create!(),
      BomStructure.create!()
    ])
  end

  it "renders a list of bom_structures" do
    render
    cell_selector = 'div>p'
  end
end
