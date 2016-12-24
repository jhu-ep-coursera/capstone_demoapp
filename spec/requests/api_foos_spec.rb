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

  context "a specific Foo exists" do
    let(:foo) { FactoryGirl.create(:foo) }
    let(:bad_id) { 1234567890 }

    it "returns Foo when using correct ID" do
      get foo_path(foo.id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body

      payload=parsed_body
      expect(payload).to have_key("id")
      expect(payload).to have_key("name")
      expect(payload["id"]).to eq(foo.id)
      expect(payload["name"]).to eq(foo.name)
    end

    it "returns not found when using incorrect ID" do
      get foo_path(bad_id)
      #pp parsed_body
      expect(response).to have_http_status(:not_found)
      expect(response.content_type).to eq("application/json") 

      payload=parsed_body
      expect(payload).to have_key("errors")
      expect(payload["errors"]).to have_key("full_messages")
      expect(payload["errors"]["full_messages"][0]).to include("cannot","#{bad_id}")
    end
  end

  context "create a new Foo" do
    let(:foo_state) { FactoryGirl.attributes_for(:foo) }

    it "can create with provided name" do
      jpost foos_path, foo_state
      #pp parsed_body
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq("application/json") 

      #check the payload of the response
      payload=parsed_body
      expect(payload).to have_key("id")
      expect(payload).to have_key("name")
      expect(payload["name"]).to eq(foo_state[:name])
      id=payload["id"]

      # verify we can locate the created instance in DB
      expect(Foo.find(id).name).to eq(foo_state[:name])
    end
  end

  context "existing Foo" do
    let(:foo) { FactoryGirl.create(:foo) }
    let(:new_name) { "testing" }

    it "can update name" do
      #verify name is not yet the new name
      expect(foo.name).to_not eq(new_name)

      # change to the new name
      jput foo_path(foo.id), {:name=>new_name}
      expect(response).to have_http_status(:no_content)

      # verify we can locate the created instance in DB
      expect(Foo.find(foo.id).name).to eq(new_name)
    end

    it "can be deleted"
  end
end
