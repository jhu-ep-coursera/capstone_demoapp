require 'rails_helper'

describe Foo, type: :model do

  context "valid foo" do
    it "has a name" do
      foo=Foo.create(:name=>"test")
      expect(foo).to be_valid
      expect(foo.name).to_not be_nil
    end
  end

end
