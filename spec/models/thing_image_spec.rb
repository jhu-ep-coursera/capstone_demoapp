require 'rails_helper'

RSpec.describe ThingImage, type: :model do
  include_context "db_cleanup_each"

  context "valid thing" do
    let(:thing) { FactoryGirl.build(:thing) }

    it "build image for thing and save" do
      ti = FactoryGirl.build(:thing_image, :thing=>thing)
      ti.save!
      expect(thing).to be_persisted
      expect(ti).to be_persisted
      expect(ti.image).to_not be_nil
      expect(ti.image).to be_persisted
    end

    it "relate multiple images" do
      thing.thing_images << FactoryGirl.build_list(:thing_image, 3, :thing=>thing)
      thing.save!
      expect(Thing.find(thing.id).thing_images.size).to eq(3)

      thing.thing_images.each do |ti|
        expect(ti.image.things.first).to eql(thing) #same instance
      end
      byebug
    end

    it "build images using factory" do
      thing=FactoryGirl.create(:thing, :with_image, :image_count=>2)
      expect(Thing.find(thing.id).thing_images.size).to eq(2)
      thing.thing_images.each do |ti|
        expect(ti.image.things.first).to eql(thing) #same instance
      end
    end
  end

  context "related thing and image" do
    let(:thing) { FactoryGirl.create(:thing, :with_image) }
    let(:thing_image) { thing.thing_images.first }
    before(:each) do
      #sanity check that objects and relationships are in place
      expect(ThingImage.where(:id=>thing_image.id).exists?).to be true
      expect(Image.where(:id=>thing_image.image_id).exists?).to be true
      expect(Thing.where(:id=>thing_image.thing_id).exists?).to be true
    end
    after(:each)  do
      #we always expect the thing_image to be deleted during each test
      expect(ThingImage.where(:id=>thing_image.id).exists?).to be false
    end

    it "deletes link but not image when thing removed" do
      thing.destroy
      expect(Image.where(:id=>thing_image.image_id).exists?).to be true
      expect(Thing.where(:id=>thing_image.thing_id).exists?).to be false
    end

    it "deletes link but not thing when image removed" do
      thing_image.image.destroy
      expect(Image.where(:id=>thing_image.image_id).exists?).to be false
      expect(Thing.where(:id=>thing_image.thing_id).exists?).to be true
    end
  end
end
