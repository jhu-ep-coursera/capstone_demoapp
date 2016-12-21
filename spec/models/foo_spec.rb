require 'rails_helper'

describe Foo, type: :model do

  it "created Foo will be persisted, have a name, and be found" do
    foo=Foo.create(:name => "test");
    expect(foo).to be_persisted
    expect(foo.name).to eq("test")
    expect(Foo.find(foo.id)).to_not be_nil
  end
end
