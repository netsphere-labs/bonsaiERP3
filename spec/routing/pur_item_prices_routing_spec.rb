require "rails_helper"

RSpec.describe PurItemPricesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/pur_item_prices").to route_to("pur_item_prices#index")
    end

    it "routes to #new" do
      expect(get: "/pur_item_prices/new").to route_to("pur_item_prices#new")
    end

    it "routes to #show" do
      expect(get: "/pur_item_prices/1").to route_to("pur_item_prices#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/pur_item_prices/1/edit").to route_to("pur_item_prices#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/pur_item_prices").to route_to("pur_item_prices#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/pur_item_prices/1").to route_to("pur_item_prices#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/pur_item_prices/1").to route_to("pur_item_prices#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/pur_item_prices/1").to route_to("pur_item_prices#destroy", id: "1")
    end
  end
end
