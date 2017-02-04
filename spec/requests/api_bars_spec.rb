require 'rails_helper'

RSpec.describe "Bar API", type: :request do
  include_context "db_cleanup_each"
  let(:user) { login signup(FactoryGirl.attributes_for(:user)) }

  context "caller requests list of Bars" do
    it_should_behave_like "resource index", :bar do
      let(:response_check) do
        #pp payload
        expect(payload.count).to eq(resources.count);
        expect(payload.map{|f|f["name"]}).to eq(resources.map{|f|f[:name]})
      end
    end

  end

  context "a specific Bar exists" do
    it_should_behave_like "show resource", :bar do
      let(:response_check) do
        #pp payload
        expect(payload).to have_key("id")
        expect(payload).to have_key("name")
        expect(payload["id"]).to eq(resource.id.to_s)
        expect(payload["name"]).to eq(resource.name)
      end
    end
  end

  context "create a new Bar" do
    it_should_behave_like "create resource", :bar do
      let(:response_check) {
        #pp payload
        expect(payload).to have_key("name")
        expect(payload["name"]).to eq(resource_state[:name])

        # verify we can locate the created instance in DB
        expect(Bar.find(resource_id).name).to eq(resource_state[:name])
      }
    end
  end

  context "existing Bar" do
    it_should_behave_like "modifiable resource", :bar do
      let(:update_check) {
        #verify name is not yet the new name
        expect(resource["name"]).to_not eq(new_state[:name])
        # verify DB has instance updated with name
        expect(Bar.find(resource["id"]).name).to eq(new_state[:name])
      }
    end
  end
end
