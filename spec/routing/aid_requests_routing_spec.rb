require "rails_helper"

RSpec.describe AidRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/aid_requests").to route_to("aid_requests#index")
    end

    it "routes to #new" do
      expect(get: "/aid_requests/new").to route_to("aid_requests#new")
    end

    it "routes to #show" do
      expect(get: "/aid_requests/1").to route_to("aid_requests#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/aid_requests/1/edit").to route_to("aid_requests#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/aid_requests").to route_to("aid_requests#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/aid_requests/1").to route_to("aid_requests#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/aid_requests/1").to route_to("aid_requests#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/aid_requests/1").to route_to("aid_requests#destroy", id: "1")
    end
  end
end
