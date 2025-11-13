
require 'rails_helper'

RSpec.describe ContactAccount, type: :model do
  it "sets a new instance with defaults" do
    c = ContactAccount.new
    c.type.should eq('ContactAccount')
  end
end
