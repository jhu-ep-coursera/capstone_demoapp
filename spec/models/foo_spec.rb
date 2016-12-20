require 'rails_helper'

describe Foo, type: :model do

  context "created Foo (let)" do
    let(:foo) { Foo.create(:name => "test") }

    it { expect(foo).to be_persisted }
    it { expect(foo.name).to eq("test") }
    it { expect(Foo.find(foo.id)).to_not be_nil }
  end

  context "created Foo (subject)" do
    subject { Foo.create(:name => "test") }

    it { is_expected.to be_persisted }
    it { expect(subject.name).to eq("test") }
    it { expect(Foo.find(subject.id)).to_not be_nil }
  end

end
