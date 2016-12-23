require 'rails_helper'

RSpec.describe "Foo API", type: :request do
  include_context "db_cleanup_each", :transaction

  context "caller requests list of Foos" do
    let!(:foos) { (1..5).map {|idx| FactoryGirl.create(:foo) } }

    it "returns all instances" do
      get foos_path, {:sample1=>"param",:sample2=>"param"},
                     {"Accept"=>"application/json"}
      expect(request.method).to eq("GET")
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")
      expect(response["X-Frame-Options"]).to eq("SAMEORIGIN")

      payload=parsed_body
      expect(payload.count).to eq(foos.count)
      expect(payload.map{|f|f["name"]}).to eq(foos.map{|f|f[:name]})
    end
  end
end
