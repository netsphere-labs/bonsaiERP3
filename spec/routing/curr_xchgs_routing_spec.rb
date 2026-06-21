require "rails_helper"

RSpec.describe CurrXchgsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/curr_xchgs").to route_to("curr_xchgs#index")
    end

    it "routes to #new" do
      expect(get: "/curr_xchgs/new").to route_to("curr_xchgs#new")
    end

    it "routes to #show" do
      expect(get: "/curr_xchgs/1").to route_to("curr_xchgs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/curr_xchgs/1/edit").to route_to("curr_xchgs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/curr_xchgs").to route_to("curr_xchgs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/curr_xchgs/1").to route_to("curr_xchgs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/curr_xchgs/1").to route_to("curr_xchgs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/curr_xchgs/1").to route_to("curr_xchgs#destroy", id: "1")
    end
  end
end
