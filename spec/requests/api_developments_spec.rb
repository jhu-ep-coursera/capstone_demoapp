require 'rails_helper'

RSpec.describe "ApiDevelopments", type: :request do
  include_context "db_cleanup_each"
  def parsed_body
    JSON.parse(response.body)
  end

  describe "RDBMS-backed" do
    it "create RDBMS-backed model" do
      object=FactoryGirl.create(:foo, :name=>"test")
      expect(Foo.find(object.id).name).to eq("test")
    end

    it "expose RDBMS-backed API resource" do
      object=FactoryGirl.create(:foo, :name=>"test")
      expect(foos_path).to eq("/api/foos")
      get foo_path(object.id)
      expect(response).to have_http_status(:ok)
      expect(parsed_body["name"]).to eq("test")
    end
  end

  describe "MongoDB-backed" do
    it "create MongoDB-backed model" do
      object=FactoryGirl.create(:bar, :name=>"test")
      expect(Bar.find(object.id).name).to eq("test")
    end
    
    it "expose MongoDB-backed API resource" do
      object=FactoryGirl.create(:bar, :name=>"test")
      expect(bars_path).to eq("/api/bars")
      get bar_path(object.id) 
      expect(response).to have_http_status(:ok)
      expect(parsed_body["name"]).to eq(object.name)
      expect(parsed_body).to include("created_at")
      expect(parsed_body).to include("id"=>object.id.to_s)
    end
  end
end
