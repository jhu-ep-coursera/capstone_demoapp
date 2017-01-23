require 'rails_helper'

RSpec.describe "ThingImages", type: :request do
  include_context "db_cleanup_each"
  let(:account) { signup FactoryGirl.attributes_for(:user) }
  let!(:user) { login account }

  describe "manage thing/image relationships" do
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
      jget thing_thing_images_path(thing["id"])
      #puts parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(images.count)
      expect(parsed_body[0]).to include("image_caption")
      expect(parsed_body[0]).to_not include("thing_name")
    end
    it "can get links for Image" do
      jget image_thing_images_path(images[0]["id"])
      #puts parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body[0]).to_not include("image_caption")
      expect(parsed_body[0]).to include("thing_name"=>thing["name"])
    end
  end
  shared_examples "get linkables" do |count|
    it "return linkable things" do
      jget image_linkable_things_path(images[0]["id"])
      #puts parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(count)
      if (count > 0)
          parsed_body.each do |thing|
            expect(thing["id"]).to be_in(unlinked_things.map{|t|t["id"]})
            expect(thing).to include("description")
            expect(thing).to include("notes")
          end
      end
    end
  end
  shared_examples "can create link" do
    it "link from Thing to Image" do
      jpost thing_thing_images_path(thing["id"]), thing_image_props
      expect(response).to have_http_status(:no_content)
      jget thing_thing_images_path(thing["id"])
      expect(parsed_body.size).to eq(images.count+1)
    end
    it "link from Image to Thing" do
      jpost image_thing_images_path(thing_image_props[:image_id]), 
                                    thing_image_props.merge(:thing_id=>thing["id"])
      expect(response).to have_http_status(:no_content)
      jget thing_thing_images_path(thing["id"])
      expect(parsed_body.size).to eq(images.count+1)
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
      jpost thing_thing_images_path(thing["id"]), thing_image_props
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
    let(:thing) { create_resource(things_path, :thing, :created) }
    let(:thing_image) { #return existing thing so we can modify
      jget thing_thing_images_path(thing["id"])
      expect(response).to have_http_status(:ok)
      parsed_body[0]
    }
    let(:images) { (1..3).map { create_resource(images_path, :image, :created) } }

    let!(:unlinked_things) { (1..2).map {create_resource(things_path, :thing, :created)} }
    let(:orphan_image) { FactoryGirl.create(:image) }          #unlinked image to link to thing
    let(:thing_image_props) { { :image_id=>orphan_image.id } } #payload required to link image

    before(:each) do
      images.map do |image|  #link thing and images
        jpost thing_thing_images_path(thing["id"]), {:image_id=>image["id"]}
        expect(response).to have_http_status(:no_content)
      end
    end

    context "anonymous user" do
      before(:each) { logout }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :unauthorized
      it_should_behave_like "cannot update link", :unauthorized
      it_should_behave_like "cannot delete link", :unauthorized
    end
    context "authenticated user" do
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2
      it_should_behave_like "can create link"
      it_should_behave_like "can update link"
      it_should_behave_like "can delete link"
    end
  end
end
