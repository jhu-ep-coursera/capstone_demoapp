require 'rails_helper'

RSpec.describe "Images", type: :request do
  include_context "db_cleanup_each"
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  context "quick API check" do
    let!(:user) { login account }

    it_should_behave_like "resource index", :image
    it_should_behave_like "show resource", :image
    it_should_behave_like "create resource", :image
    it_should_behave_like "modifiable resource", :image
  end

  shared_examples "cannot create" do
    it "create fails" do
      jpost images_path, image_props
      expect(response.status).to be >= 400
      expect(response.status).to be < 500
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "can create" do
    it "can create" do
      jpost images_path, image_props
      expect(response).to have_http_status(:created)
      payload=parsed_body
      expect(payload).to include("id")
      expect(payload).to include("caption"=>image_props[:caption])
    end
  end
  shared_examples "all fields present" do
    it "list has all fields" do
      jget images_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include("id")
        expect(r).to include("caption")
      end
    end
    it "get has all fields" do
      jget image_path(image.id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>image.id)
      expect(payload).to include("caption"=>image.caption)
    end
  end

  describe "access" do
    let(:images_props) { (1..3).map {FactoryGirl.attributes_for(:image, :with_caption)} }
    let(:image_props) { images_props[0] }
    let!(:images) { Image.create(images_props) }
    let(:image) { images[0] }

    context "unauthenticated caller" do
      before(:each) { logout nil }
      it_should_behave_like "cannot create"
      it_should_behave_like "all fields present"
    end
    context "authenticated caller" do
      let!(:user) { login account }
      it_should_behave_like "can create"
      it_should_behave_like "all fields present"
    end
  end
end
