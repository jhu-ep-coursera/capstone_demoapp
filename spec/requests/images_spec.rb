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

  shared_examples "cannot create" do |status=:unauthorized|
    it "create fails with #{status}" do
      jpost images_path, image_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot update" do |status|
    it "update fails with #{status}" do
      jput image_path(image_id), FactoryGirl.attributes_for(:image)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot delete" do |status|
    it "delete fails with #{status}" do
      jdelete image_path(image_id), image_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "can create" do
    it "is created" do
      jpost images_path, image_props
      #pp parsed_body
      expect(response).to have_http_status(:created)
      payload=parsed_body
      expect(payload).to include("id")
      expect(payload).to include("caption"=>image_props[:caption])
      expect(payload).to include("user_roles")
      expect(payload["user_roles"]).to include(Role::ORGANIZER)
      expect(Role.where(:user_id=>user["id"],:role_name=>Role::ORGANIZER)).to exist
    end
  end
  shared_examples "can update" do
    it "can update" do
      jput image_path(image_id), image_props
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "can delete" do
    it "can delete" do
      jdelete image_path(image_id)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "all fields present" do |user_roles|
    it "list has all fields with user_roles #{user_roles}" do
      jget images_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include("id")
        expect(r).to include("caption")
        if user_roles.empty?
          expect(r).to_not include("user_roles")
        else
          expect(r).to include("user_roles")
          expect(r["user_roles"].to_a).to include(*user_roles)
        end
      end
    end
    it "get has all fields with user_roles #{user_roles}" do
      jget image_path(image_id)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>image.id)
      expect(payload).to include("caption"=>image.caption)
      if user_roles.empty?
        expect(payload).to_not include("user_roles")
      else
        expect(payload).to include("user_roles")
        expect(payload["user_roles"].to_a).to include(*user_roles)
      end
    end
  end

  describe "Image authorization" do
    let(:alt_account) { signup FactoryGirl.attributes_for(:user) }
    let(:admin_account) { apply_admin(signup FactoryGirl.attributes_for(:user)) }
    let(:image_props) { FactoryGirl.attributes_for(:image, :with_caption) }
    let(:image_resources) { 3.times.map { create_resource images_path, :image } }
    let(:image_id)  { image_resources[0]["id"] }
    let(:image)     { Image.find(image_id) }


    context "caller is unauthenticated" do
      before(:each) { login account; image_resources; logout }
      it_should_behave_like "cannot create"
      it_should_behave_like "cannot update", :unauthorized
      it_should_behave_like "cannot delete", :unauthorized
      it_should_behave_like "all fields present", []
    end
    context "caller is authenticated organizer" do
      let!(:user)   { login account }
      before(:each) { image_resources }
      it_should_behave_like "can create"
      it_should_behave_like "can update"
      it_should_behave_like "can delete"
      it_should_behave_like "all fields present", [Role::ORGANIZER]
    end
    context "caller is authenticated non-organizer" do
      before(:each) { login account; image_resources; login alt_account }
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "all fields present", []
    end
    context "caller is admin" do
      before(:each) { login account; image_resources; login admin_account }
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "can delete"
      it_should_behave_like "all fields present", []
    end
  end
end
