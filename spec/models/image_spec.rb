require 'rails_helper'

RSpec.describe Image, type: :model do
  include_context "db_cleanup"

  context "build valid image" do
    it "default image created with random caption" do
      image=FactoryGirl.build(:image)
      expect(image.creator_id).to_not be_nil
      expect(image.save).to be true
    end

    it "image with User and non-nil caption" do
      user=FactoryGirl.create(:user)
      image=FactoryGirl.build(:image, :with_caption, :creator_id=>user.id)
      expect(image.creator_id).to eq(user.id)
      expect(image.caption).to_not be_nil
      expect(image.save).to be true      
    end

    it "image with explicit nil caption" do
      image=FactoryGirl.build(:image, caption:nil)
      expect(image.creator_id).to_not be_nil
      expect(image.caption).to be_nil
      expect(image.save).to be true
    end
  end
end
