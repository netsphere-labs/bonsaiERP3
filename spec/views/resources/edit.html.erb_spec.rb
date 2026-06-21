require 'rails_helper'

RSpec.describe "resources/edit", type: :view do
  let(:resource) {
    Resource.create!()
  }

  before(:each) do
    assign(:resource, resource)
  end

  it "renders the edit resource form" do
    render

    assert_select "form[action=?][method=?]", resource_path(resource), "post" do
    end
  end
end
