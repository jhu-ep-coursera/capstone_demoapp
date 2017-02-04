require 'rails_helper'

RSpec.describe "ThingImages", type: :request do
  include_context "db_cleanup_each"
  #originator becomes organizer after creation
  let(:originator) { apply_originator(signup(FactoryGirl.attributes_for(:user)), Thing) }

  describe "manage thing/image relationships" do
    let!(:user) { login originator }
    context "valid thing and image" do
      let(:thing) { create_resource(things_path, :thing, :created) }
      let(:image) { create_resource(images_path, :image, :created) }
      let(:thing_image_props) { 
        FactoryGirl.attributes_for(:thing_image, :image_id=>image["id"]) 
      }

      it "can associate image with thing" do
        #associated the Image to the Thing
        jpost thing_thing_images_path(thing["id"]), thing_image_props
        expect(response).to have_http_status(:no_content)

        #get ThingImages for Thing and verify associated with Image
        jget thing_thing_images_path(thing["id"])
        expect(response).to have_http_status(:ok)
        #puts response.body
        payload=parsed_body
        expect(payload.size).to eq(1)
        expect(payload[0]).to include("image_id"=>image["id"])
        expect(payload[0]).to include("image_caption"=>image["caption"])
      end

      it "must have image" do
        jpost thing_thing_images_path(thing["id"]), 
              thing_image_props.except(:image_id)
        expect(response).to have_http_status(:bad_request)
        payload=parsed_body
        expect(payload).to include("errors")
        expect(payload["errors"]["full_messages"]).to include(/param/,/missing/)
      end
    end
  end

  shared_examples "can get links" do
    it "can get links for Thing" do
      jget thing_thing_images_path(linked_thing_id)
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(linked_image_ids.count)
      expect(parsed_body[0]).to include("image_caption")
      expect(parsed_body[0]).to_not include("thing_name")
    end
    it "can get links for Image" do
      jget image_thing_images_path(linked_image_id)
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body[0]).to_not include("image_caption")
      expect(parsed_body[0]).to include("thing_name"=>linked_thing["name"])
    end
  end
  shared_examples "get linkables" do |count, user_roles=[]|
    it "return linkable things" do
      jget image_linkable_things_path(linked_image_ids[0])
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(count)
      if (count > 0)
          parsed_body.each do |thing|
            expect(thing["id"]).to be_in(unlinked_thing_ids)
            expect(thing).to include("description")
            expect(thing).to include("notes")
            expect(thing).to include("user_roles")
            expect(thing["user_roles"]).to include(*user_roles)
          end
      end
    end
  end
  shared_examples "can create link" do
    it "link from Thing to Image" do
      jpost thing_thing_images_path(linked_thing_id), thing_image_props
      expect(response).to have_http_status(:no_content)
      jget thing_thing_images_path(linked_thing_id)
      expect(parsed_body.size).to eq(linked_image_ids.count+1)
    end
    it "link from Image to Thing" do
      jpost image_thing_images_path(thing_image_props[:image_id]), 
                                    thing_image_props.merge(:thing_id=>linked_thing_id)
      expect(response).to have_http_status(:no_content)
      jget thing_thing_images_path(linked_thing_id)
      expect(parsed_body.size).to eq(linked_image_ids.count+1)
    end
    it "bad request when link to unknown Image" do
      jpost thing_thing_images_path(linked_thing_id), 
                                    thing_image_props.merge(:image_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
    it "bad request when link to unknown Thing" do
      jpost image_thing_images_path(thing_image_props[:image_id]), 
                                    thing_image_props.merge(:thing_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
  end
  shared_examples "can update link" do
    it do
      jput thing_thing_image_path(thing_image["thing_id"], thing_image["id"]), 
                             thing_image.merge("priority"=>0)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "can delete link" do
    it do
      jdelete thing_thing_image_path(thing_image["thing_id"], thing_image["id"])
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "cannot create link" do |status|
    it do
      jpost thing_thing_images_path(linked_thing_id), thing_image_props
      expect(response).to have_http_status(status)
    end
  end
  shared_examples "cannot update link" do |status|
    it do
      jput thing_thing_image_path(thing_image["thing_id"], thing_image["id"]), 
                             thing_image.merge("priority"=>0)
      expect(response).to have_http_status(status)
    end
  end
  shared_examples "cannot delete link" do |status|
    it do
      jdelete thing_thing_image_path(thing_image["thing_id"], thing_image["id"])
      expect(response).to have_http_status(status)
    end
  end


  describe "ThingImage Authn policies" do
    let(:account)         { signup FactoryGirl.attributes_for(:user) }
    let(:thing_resources) { 3.times.map { create_resource(things_path, :thing, :created) } }
    let(:image_resources) { 4.times.map { create_resource(images_path, :image, :created) } }
    let(:things)          { thing_resources.map {|t| Thing.find(t["id"]) } }
    let(:linked_thing)    { things[0] }
    let(:linked_thing_id) { linked_thing.id }
    let(:linked_image_ids)  { (0..2).map {|idx| image_resources[idx]["id"] } }
    let(:unlinked_thing_ids){ (1..2).map {|idx| thing_resources[idx]["id"] } }
    let(:linked_image_id)   { image_resources[0]["id"] }
    let(:orphan_image_id)   { image_resources[3]["id"] }     #unlinked image to link to thing
    let(:thing_image_props) { { :image_id=>orphan_image_id } } #payload required to link image
    let(:thing_image)       { #return existing thing so we can modify
      jget thing_thing_images_path(linked_thing_id)
      expect(response).to have_http_status(:ok)
      parsed_body[0]
    }
    before(:each) do
      login originator
      thing_resources
      image_resources
      linked_image_ids.each do |image_id| #link thing and images, leave orphans
        jpost thing_thing_images_path(linked_thing_id), {:image_id=>image_id}
        expect(response).to have_http_status(:no_content)
      end
    end

    context "user is anonymous" do
      before(:each) { logout }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :unauthorized
      it_should_behave_like "cannot update link", :unauthorized
      it_should_behave_like "cannot delete link", :unauthorized
    end
    context "user is authenticated" do
      before(:each) { login account }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :forbidden
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "cannot delete link", :forbidden
    end
    context "user is member" do
      before(:each) do
        login apply_member(account, things) 
      end
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2, [Role::MEMBER]
      it_should_behave_like "can create link"
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "cannot delete link", :forbidden
    end
    context "user is organizer" do
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2, [Role::ORGANIZER]
      it_should_behave_like "can create link"
      it_should_behave_like "can update link"
      it_should_behave_like "can delete link"
    end
    context "user is admin" do
      before(:each) { login apply_admin(account) }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :forbidden
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "can delete link"
    end
  end
end
