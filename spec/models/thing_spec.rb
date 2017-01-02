require 'rails_helper'

RSpec.describe Thing, type: :model do
  include_context "db_cleanup_each"

  context "valid thing" do
    let(:thing) { FactoryGirl.create(:thing) }

    it "creates new instance" do
      db_thing=Thing.find(thing.id)
      expect(db_thing.name).to eq(thing.name)
    end
  end

  context "invalid thing" do
    let(:thing) { FactoryGirl.build(:thing, :name=>nil) }

    it "provides error messages" do
      expect(thing.validate).to be false
      expect(thing.errors.messages).to include(:name=>["can't be blank"])
    end
  end
end
