require 'rails_helper'

RSpec.describe "Location", type: :model do

  describe "PostalAddress" do
    subject { PostalAddress.new("3400 North Charles Street", "Baltimore", "MD", "21218", "US") }
    it { expect(subject.street_address).to eq("3400 North Charles Street") }
    it { expect(subject.city).to eq("Baltimore") }
    it { expect(subject.state_code).to eq("MD") }
    it { expect(subject.zip).to eq("21218") }
    it { expect(subject.country_code).to eq("US") }
    it { expect(subject.to_hash).to include(
        street_address:"3400 North Charles Street", 
        city: "Baltimore", 
        state_code: "MD", 
        zip: "21218", 
        country_code: "US") }
  end

  describe "Location" do
    let(:address) { PostalAddress.new("3400 North Charles Street", "Baltimore", "MD", "21218", "US") }
    let(:position) { Point.new(-76.6200464, 39.3304957) }
    subject            { Location.new("3400 N Charles St, Baltimore, MD 21218, USA", position, address) }
    let(:alt_location) { Location.new("A Place, 3400 N Charles St, Baltimore, MD 21218, USA", position, address) }

    it { expect(subject.to_hash).to include(formatted_address:"3400 N Charles St, Baltimore, MD 21218, USA") } 
    it { expect(subject.to_hash).to include(position:position.to_hash) } 
    it { expect(subject.to_hash).to include(address:address.to_hash) } 
    it { expect(subject).to eq(Location.new("3400 N Charles St, Baltimore, MD 21218, USA", position, address)) }
    it { expect(subject).to_not eq(alt_location) }
    it { expect(subject).to be ===(alt_location) }
  end

  describe "Location Factories" do
    context "Point Factory" do
      subject { FactoryGirl.build(:point) }
      it { expect(subject.lng).to be_a Float }
      it { expect(subject.lat).to be_a Float }
    end
    context "Address Factory" do
      subject { FactoryGirl.build(:postal_address) }
      it { expect(subject.street_address).to be_a String }
      it { expect(subject.city).to be_a String }
      it { expect(subject.state_code).to be_a String }
      it { expect(subject.zip).to be_a String }
      it { expect(subject.country_code).to be_a String }
    end
    context "Location Factory" do
      subject { FactoryGirl.build(:location) }
      it { expect(subject.formatted_address).to be_a String }
      it { expect(subject.position).to be_a Point }
      it { expect(subject.address).to be_a PostalAddress }
      it { expect(subject.position.lng).to be_a Float }
      it { expect(subject.position.lat).to be_a Float }
      it { expect(subject.address.street_address).to be_a String }
      it { expect(subject.address.city).to be_a String }
      it { expect(subject.address.state_code).to be_a String }
      it { expect(subject.address.zip).to be_a String }
      it { expect(subject.address.country_code).to be_a String }
    end
  end
end
