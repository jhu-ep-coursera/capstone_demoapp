require 'rails_helper'

describe Foo, type: :model do

  context "created Foo" do
    before(:each) do
      @foo=Foo.create(:name => "test")
    end
    after(:each) do
      @foo.delete
    end

    it "will be persisted, have a name, and be found" do
      expect(@foo).to be_persisted
      expect(@foo.name).to eq("test")
      expect(Foo.find(@foo.id)).to_not be_nil
    end
  end
end
