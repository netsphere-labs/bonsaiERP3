require "rails_helper"

RSpec.describe BomStructuresController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/bom_structures").to route_to("bom_structures#index")
    end

    it "routes to #new" do
      expect(get: "/bom_structures/new").to route_to("bom_structures#new")
    end

    it "routes to #show" do
      expect(get: "/bom_structures/1").to route_to("bom_structures#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/bom_structures/1/edit").to route_to("bom_structures#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/bom_structures").to route_to("bom_structures#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/bom_structures/1").to route_to("bom_structures#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/bom_structures/1").to route_to("bom_structures#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/bom_structures/1").to route_to("bom_structures#destroy", id: "1")
    end
  end
end
