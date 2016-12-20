require 'rails_helper'

describe Foo, type: :model do

  context "created Foo" do
    let(:foo) { Foo.create(:name => "test") }

    it { expect(foo).to be_persisted }
    it { expect(foo.name).to eq("test") }
    it { expect(Foo.find(foo.id)).to_not be_nil }
  end
end
