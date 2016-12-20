require 'rails_helper'

describe Foo, type: :model do

  context "created Foo" do
    let(:foo) { Foo.create(:name => "test") }

    it "will be persisted" do
      expect(foo).to_not be_persisted   #causing an error
    end
    it "will have a name" do
      expect(foo.name).to eq("test")
    end
    it "will be found" do
      expect(Foo.find(foo.id)).to_not be_nil
    end
  end
end
