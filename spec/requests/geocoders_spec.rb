require 'rails_helper'

RSpec.describe "Geocoders", type: :request do
  include_context "db_cleanup"
  let(:jhu)      { FactoryGirl.build(:location,:jhu) }
  let(:address)  { jhu.address }
  let(:position) { jhu.position }
  let(:search_address)  { address.full_address.match("^(.*) #{address.zip}")[1] }
  let(:search_position) { position }
  let(:user)     { signup FactoryGirl.attributes_for(:user) }

  describe "geocoding" do
    let(:geocoder) { Geocoder.new }
    context "service" do
      it "locates location by address" do
        loc=geocoder.geocode search_address
        #pp "search address=#{search_address}"
        #pp loc.to_hash
        expect(loc.formatted_address).to eq(jhu.formatted_address)
        expect(loc.position===jhu.position).to be true
        expect(loc.address).to eq(jhu.address)
        expect(loc).to eq(jhu)
      end

      it "locates location by position" do
        loc=geocoder.reverse_geocode search_position
        #pp "search position=#{search_position.to_hash}"
        #pp loc.to_hash
        expect(loc.formatted_address).to eq(jhu.formatted_address)
        expect(loc.position===jhu.position).to be true
        expect(loc.address).to eq(jhu.address)
        expect(loc).to eq(jhu)
      end
    end

    context "API" do
      let(:geo)  { geocoder.geocode address.full_address }
      let(:rgeo) { geocoder.reverse_geocode position }
      it "locates location by address" do
        jget geocoder_addresses_path, :address=>search_address
        #pp "search address=#{search_address}"
        #pp parsed_body
        #pp "Cache-Control=#{response.header['Cache-Control']}"
        expect(response).to have_http_status(:ok)
        payload=parsed_body

        expect(payload).to include("formatted_address"=>geo.formatted_address)
        expect(payload).to include("position"=>geo.position.to_hash.stringify_keys)
        expect(payload).to include("address"=>geo.address.to_hash.stringify_keys)
        expect(response.header).to include("Cache-Control")
        expect(response.header["Cache-Control"].match(/max-age=(\d+),/)[1]).to eq("86400")
      end

      it "locates location by position" do
        jget geocoder_positions_path, search_position.to_hash
        #pp "search position=#{search_position.to_hash}"
        #pp parsed_body
        #pp "Cache-Control=#{response.header['Cache-Control']}"
        expect(response).to have_http_status(:ok)
        payload=parsed_body

        expect(payload).to include("formatted_address"=>rgeo.formatted_address)
        expect(payload).to include("position"=>rgeo.position.to_hash.stringify_keys)
        expect(payload).to include("address"=>rgeo.address.to_hash.stringify_keys)
        expect(response.header).to include("Cache-Control")
        expect(response.header["Cache-Control"].match(/max-age=(\d+),/)[1]).to eq("86400")
      end
    end
  end

  describe "geocode cache" do
    include_context "db_scope"
    let(:geocoder_cache)    { GeocoderCache.new(Geocoder.new) }
    before(:each) do
      expect(CachedLocation.by_address(search_address).count).to be <= 1
      expect(CachedLocation.by_position(search_position).count).to be <= 1
    end

    context "service" do
      it "caches location by address" do
        expect(result=geocoder_cache.geocode(search_address)).to_not be_nil
        expect(CachedLocation.by_address(search_address).count).to eq(1)

        3.times do
          expect(geocoder_cache.geocode(search_address)[1].id).to eq(result[1].id)
          expect(CachedLocation.by_address(search_address).count).to eq(1)
        end
      end
      it "caches location by position" do
        expect(result=geocoder_cache.reverse_geocode(search_position)).to_not be_nil
        expect(CachedLocation.by_position(search_position).count).to eq(1)

        3.times do
          expect(geocoder_cache.reverse_geocode(search_position)[1].id).to eq(result[1].id)
          expect(CachedLocation.by_position(search_position).count).to eq(1)
        end
      end
    end

    context "API" do
      it "caches location by address" do
        jget geocoder_addresses_path, {:address=>search_address}
        expect(response).to have_http_status(:ok)
        expect(CachedLocation.by_address(search_address).count).to eq(1)
        #pp parsed_body

        #with request header
        3.times do 
          etag = response.headers["ETag"]
          #pp "ETag=#{etag}"
          jget geocoder_addresses_path, {:address=>search_address}, {"If-None-Match"=>etag}
          expect(response).to have_http_status(:not_modified)
          expect(CachedLocation.by_address(search_address).count).to eq(1)
        end

        #no request header
        cache=nil
        3.times do
          jget geocoder_addresses_path, {:address=>search_address}
          expect(response).to have_http_status(:ok)
          expect(CachedLocation.by_address(search_address).count).to eq(1)
        end
      end

      it "caches location by position" do
        jget geocoder_positions_path, search_position.to_hash
        expect(response).to have_http_status(:ok)
        expect(CachedLocation.by_position(search_position).count).to eq(1)
        #pp parsed_body

        #no request header
        3.times do
          jget geocoder_positions_path, search_position.to_hash
          expect(response).to have_http_status(:ok)
          expect(CachedLocation.by_position(search_position).count).to eq(1)
        end

        #with request header
        3.times do 
          etag = response.headers["ETag"]
          #pp "ETag=#{etag}"
          jget geocoder_positions_path, search_position.to_hash, {"If-None-Match"=>etag}
          expect(response).to have_http_status(:not_modified)
          expect(CachedLocation.by_position(search_position).count).to eq(1)
        end
      end
    end
  end


  describe "Image position" do
    it "can return Image position" do
      image=FactoryGirl.create(:image)
      jget image_path(image.id)
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      payload=parsed_body
      expect(payload["id"]).to eq(image.id)
      expect(payload["position"]).to_not be_nil
      expect(payload["position"].symbolize_keys).to eq(image.position.to_hash)
    end

    it "can set Image position" do
      login user
      image_props = FactoryGirl.attributes_for(:image)
      #pp image_props.except(:image_content)
      jpost images_path, image_props
      #pp parsed_body
      expect(response).to have_http_status(:created)

      payload=parsed_body
      expect(payload["position"]).to_not be_nil
      expect(payload["position"].symbolize_keys).to eq(image_props[:position])
    end
  end

  def create_images_near origin, miles, count
    images_created = []
    begin
      image=nil
      begin
        image=FactoryGirl.build(:image,image_content:nil)
      end while image.distance_from(origin) >= miles
      image.save
      images_created << image.id
    end while images_created.size < count
    images_created
  end

  describe "search" do
    include_context "db_clean_all"
    before(:each) do
      unless Thing.exists?
        10.times do 
          thing=FactoryGirl.create(:thing)
          2.times do |idx|
            image=FactoryGirl.create(:image,image_content:nil)
            thing.thing_images.create(:priority=>idx, :image=>image, :creator_id=>user[:id])
          end
        end
      end
      @origin=FactoryGirl.build(:point)
      distances=ThingImage.with_distance(@origin, ThingImage.things).map {|ti| ti.distance } 
      @distance=distances.reduce(:+) / distances.size.to_f
    end

    describe "search origin" do
      it "within range by position" do
        results=ThingImage.within_range(@origin, @distance)
        jget subjects_path, {miles:@distance}.merge(@origin.to_hash)
        #pp parsed_body
        expect(response).to have_http_status(:ok)

        payload=parsed_body
        expect(payload.size).to eq(results.size)
        expect(payload[0]).to include("thing_id", "thing_name")
        expect(payload[0]).to include("image_id", "image_caption", "image_content_url")
        expect(payload[0]).to include("position")
      end
    end

    describe "search subject" do
      include_context "db_clean_after"

      it "finds things" do
        results=ThingImage.within_range(@origin, @distance).things
        expect(results.size).to be > 0
        jget subjects_path, {miles:@distance,subject:Thing.name}.merge(@origin.to_hash)
        #pp parsed_body
        expect(response).to have_http_status(:ok)

        payload=parsed_body
        expect(payload.size).to eq(results.size)
        payload.each do |ti|
          expect(ti["thing_id"]).to_not be_nil
          expect(ti["priority"]).to eq(0)
          expect(ti["image_id"]).to_not be_nil
        end
      end

      it "finds images" do
        expect(ThingImage.within_range(@origin, @distance).things.size).to be > 0
        images_without_things = create_images_near @origin, 10, 10
        jget subjects_path, {miles:100,distance:true}.merge(@origin.to_hash)
        #pp parsed_body
        expect(response).to have_http_status(:ok)
        payload=parsed_body
      
        expect(payload.size).to be >= images_without_things.size
        found=0
        payload.each do |ti|
          found += 1 if images_without_things.include? ti["image_id"]
        end
        expect(found).to eq(images_without_things.size)
      end
    end

    shared_examples "ordered" do |direction|
      it "ordered" do
        results=ThingImage.within_range(@origin, @distance)
        jget subjects_path, {miles:@distance,distance:true,order:direction}.merge(@origin.to_hash)
        #pp parsed_body
        expect(response).to have_http_status(:ok)

        payload=parsed_body
        expect(payload.size).to eq(results.size)
        last_distance=nil
        parsed_body.each do |ti|
          expect(ti).to include("distance")
          if last_distance
            expect(ti["distance"]).to be >= last_distance   if direction==:ASC
            expect(ti["distance"]).to be <= last_distance   if direction==:DESC
          end
          last_distance=ti["distance"]
        end
      end
    end

    describe "results finishing" do

      it "simple bag of results" do
        results=ThingImage.within_range(@origin, @distance)
        jget subjects_path, {miles:@distance}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)

        payload=parsed_body
        expect(payload.size).to eq(results.size)
        parsed_body.each do |ti|
          expect(ti).to_not include("distance")
        end
      end

      it "has distance from origin" do
        results=ThingImage.within_range(@origin, @distance)
        jget subjects_path, {miles:@distance,distance:true}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)

        payload=parsed_body
        expect(payload.size).to eq(results.size)
        parsed_body.each do |ti|
          expect(ti).to include("distance")
          expect(ti["distance"].class).to be 0.0.class
        end
      end

      it_should_behave_like "ordered", :ASC
      it_should_behave_like "ordered", :DESC
    end

    describe "result caching" do
      before(:each) do
        jget subjects_path, {order: :ASC}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)
        @starting_eTag=response.headers["ETag"]
      end

      it "provides cache control" do
        jget subjects_path, {miles:@distance,distance:true}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)
        #pp response.headers

        expect(response.headers).to include("Cache-Control")
        cc=response.headers["Cache-Control"]
        expect(cc).to include("max-age=60")
        expect(cc).to include("public")
      end

      it "provides cache re-validation unmodified" do
        jget subjects_path, {miles:@distance}.merge(@origin.to_hash),
                            {"IF-NONE-MATCH"=>@starting_eTag}
        expect(response).to have_http_status(:not_modified)
        expect(response.headers["ETag"]).to eq(@starting_eTag)
      end

      it "updates eTag-modified for a Thing" do
        sleep 1 #get beyond 1sec
        t=ThingImage.first.thing
        t.name="we have changed you"
        t.save

        jget subjects_path, {order: :ASC}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)
        expect(response.headers["ETag"]).to_not eq(@starting_eTag)
      end

      context "updates eTag-modified for ThingImage" do
        let(:ti) { ThingImage.first }
        before(:each) do
          sleep 1 #get beyond 1sec
        end

        it "updates last-modified for ThingImage update" do
          ti.priority += 1
          ti.save

          jget subjects_path, {miles:@distance}.merge(@origin.to_hash)
          expect(response).to have_http_status(:ok)
          expect(response.headers["ETag"]).to_not eq(@starting_eTag)
        end

        it "updates last-modified for ThingImage delete" do
          login apply_admin(user)
          jdelete thing_thing_image_path(ti.thing, ti)
          expect(response).to have_http_status(:no_content)

          jget subjects_path, {miles:@distance}.merge(@origin.to_hash)
          expect(response).to have_http_status(:ok)
          expect(response.headers["ETag"]).to_not eq(@starting_eTag)
        end
      end

      it "updates last-modified for Image" do
        sleep 1 #get beyond 1sec
        img=Image.first
        img.caption="we changed you"
        img.save

        jget subjects_path, {miles:@distance}.merge(@origin.to_hash)
        expect(response).to have_http_status(:ok)
        expect(response.headers["ETag"]).to_not eq(@starting_eTag)
      end
    end
  end
end
