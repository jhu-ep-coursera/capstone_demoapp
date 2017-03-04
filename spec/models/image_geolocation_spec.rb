require 'rails_helper'

RSpec.describe "Image Geolocation", type: :model do
  include_context "db_cleanup"

  context "properties" do
    subject { FactoryGirl.build(:image) }
    it { expect(subject).to respond_to(:lng) }
    it { expect(subject).to respond_to(:lat) }
    it { expect(subject.save).to be true }

    context "image factory" do
      include_context "db_clean_after"
      subject { FactoryGirl.create(:image, lng:-76.613111, lat:39.285848) }
      it { expect(Image.where(lng:subject.lng,lat:subject.lat).exists?).to be true }
    end
  end

  context "Point" do
    subject { FactoryGirl.build(:point) }
    it { expect(subject).to respond_to(:lng) }
    it { expect(subject).to respond_to(:lat) }
    it { expect(subject).to respond_to(:==) }
    it { expect(subject.latlng).to eq([subject.lat, subject.lng]) }
    it { expect(subject.lnglat).to eq([subject.lng, subject.lat]) }
  end

  context "Image composed_of position" do
    let(:point) { FactoryGirl.build(:point) }
    subject { FactoryGirl.create(:image, position:point) }
    it { expect(subject).to respond_to(:position) }
    it { expect(Image.find(subject.id).position.lng).to eq(subject.lng) }
    it { expect(Image.find(subject.id).position.lat).to eq(subject.lat) }
  end

  context "Images within distance of Point" do
    include_context "db_clean_all"
    let(:origin) { Image.where(:lat=>0.0).first }
    before(:all) do
      (0..90).each do |idx|
        point=Point.new(0,90-idx)
        FactoryGirl.create(:image,:image_content=>nil,:position=>point)
      end
    end

    it "finds closest" do
      closest=Image.closest(:origin=>origin).where.not(:id=>origin)
      expect(closest.first).to eql(Image.where(:lat=>1.0).first)
    end

    it "finds within range" do
      range=Image.within(13*69,:origin=>origin).where.not(:id=>origin)
      expect(range.count).to eq(13-1) #we excluded the origin
      range.each {|img| expect(img.distance_from(origin)).to be <= 13*69 }
    end

    it "finds within range ordered" do
      range=Image.within(13*69,:origin=>origin).by_distance(:origin=>origin)
      last_distance=0
      range.each do |img| 
        expect(distance=img.distance_from(origin)).to be <= 13*69
        expect(last_distance).to be <= distance
        last_distance = distance
      end
    end

    it "finds within range annotated with distance" do
      range=Image.within(13*69,:origin=>origin).where.not(:id=>origin)
      DistanceCollection.new(range).set_distance_from(origin)
      range.each do |img|
        expect(img).to respond_to(:distance)
        expect(img.distance).to be <= 13*69
      end
    end
  end

  context "ThingImage geolocation thru Image" do
    include_context "db_clean_all"
    let(:origin) { Image.where(:lat=>0.0).first }
    before(:all) do
      (0..90).each do |idx|
        thing=FactoryGirl.create(:thing)
        point=Point.new(0,90-idx)
        image=FactoryGirl.create(:image,:image_content=>nil,:position=>point)
        FactoryGirl.create(:thing_image, :thing=>thing, :image=>image, 
                                                        :priority=>idx%2)
      end
    end

    it "finds ThingImage with near Images" do
      near = ThingImage.eager_load(:image).within(10*69, :origin=>origin)
      expect(near.size).to be(10)
      near.each do |ti|
        expect(ti.image.distance_from(origin)).to be <= 10*69
      end
    end

    it "finds ThingImage with near Images with distance" do
      near = ThingImage.select("thing_images.*")
                       .select("images.lat, images.lng")
                       .joins(:image)
                       .within(10*69, :origin=>origin)
      DistanceCollection.new(near).set_distance_from(origin)
      expect(near.size).to be(10)
      near.each do |ti|
        expect(ti).to respond_to(:distance)
        expect(ti.distance).to be <= 10*69
      end
    end

    it "finds Thing near primary Image" do
      #establish expected result
      primary_in_range=0;
      ThingImage.all.each {|ti| 
        if (ti.priority==0 && ti.image.distance_from(origin) <= 10*69)
          primary_in_range+=1
        end    
      } 
      expect(primary_in_range).to be <= ThingImage.count/2

      near = ThingImage.joins(:image)
                       .within(10*69, :origin=>origin)
                       .where(:priority=>0)
      expect(near.where(:priority=>0).size).to be(primary_in_range)
      expect(near.primary).to_not be_nil
    end
  end

  describe "ThingImage geo queries" do
    include_context "db_clean_all"
    let(:origin) { Point.new(0, 0) }
    let(:sample) { ThingImage.first }
    before(:all) do
      orphan_thing=FactoryGirl.create(:thing, :name=>"orphan")
      orphan_image=FactoryGirl.create(:image, caption:"orphan",
                                      image_content:nil,
                                      position:Point.new(0,1))
      #primary and secondary images
      (0..2).each do |idx|
        thing=FactoryGirl.create(:thing)
        (0..1).each do |priority|
          image=FactoryGirl.create(:image,
            caption: (priority==0) ? "priority" : "secondary",
            image_content:nil,
            position:Point.new(0,idx))
          FactoryGirl.create(:thing_image,
                             :thing=>thing,
                             :image=>image,
                             :priority=>priority)
        end
      end
    end

    it "supplies Image and Thing info" do
      result=ThingImage.where(id:sample.id)
                        .with_name
                        .with_caption
                        .with_position
                        .first
      expect(result).to_not be_nil
      expect(result.thing_id).to eq(sample.thing.id)
      expect(result.thing_name).to eq(sample.thing.name)
      expect(result.image_id).to eq(sample.image.id)
      expect(result.image_caption).to eq(sample.image.caption)
      expect(result.lng).to eq(sample.image.lng)
      expect(result.lat).to eq(sample.image.lat)
    end

    it "returns ThingImages for Things and primary Image" do
      things=ThingImage.within_range(origin).things
      expect(things.size).to eq(3)
      things.each do |ti|
        expect(ti.priority).to eq(0)
        expect(ti.thing_id).to_not be_nil
        expect(ti.image_id).to_not be_nil
      end
    end

    it "returns ThingImages for orphan Images" do
      orphan_images=ThingImage.within_range(origin)
                              .where(:thing=>nil)
                              .with_caption
      expect(orphan_images.size).to eq(1)
      orphan_images.each do |ti|
        expect(ti.thing_id).to be_nil
        expect(ti.priority).to be_nil
        expect(ti.image_id).to_not be_nil
        expect(ti.image_caption).to_not be_nil
      end
    end

    it "supplies distance" do
      results=ThingImage.with_distance(origin, ThingImage.all)
      results.each do |ti|
        expect(ti).to respond_to(:distance)
        expect(ti.distance).to be_between(69*ti.lat,70*ti.lat)
      end
    end

    it "returns all ThingImages without limit" do
      results=ThingImage.with_distance(origin, ThingImage.within_range(origin, nil))
      expect(results.size).to eq((3*2)+1) #two assigned images and image orphan
    end

    it "returns ThingImages within limit" do
      results=ThingImage.with_distance(origin, ThingImage.within_range(origin, 70))
      expect(results.size).to eq(5)
      results.each do |ti|
        #pp "distance=#{ti.distance}"
        expect(ti.distance).to be < 70
      end
    end

    it "orders ThingImages by distance ASC" do
      results=ThingImage.with_distance(origin, ThingImage.within_range(origin, nil, false))
      expect(results.size).to eq((3*2)+1)
      last_distance=-1
      results.each do |ti|
        #pp "distance=#{ti.distance}"
        expect(ti.distance).to be >= last_distance
        last_distance = ti.distance
      end
    end

    it "orders ThingImages by distance DESC" do
      results=ThingImage.within_range(origin, nil, true)
      expect(results.size).to eq(3*2+1)
      last_distance=69*90
      results.each do |ti|
        expect(distance=ti.distance_from(origin)).to be <= last_distance
        last_distance = distance
        #pp "distance=#{distance}"
      end
    end

  end
end
