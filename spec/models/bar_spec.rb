require 'rails_helper'

require 'mongo'
Mongo::Logger.logger.level = ::Logger::DEBUG

describe Bar, :type=>:model, :orm=>:mongoid do
  before(:all) do
    Bar.delete_all
  end

  context "created Bar (let)" do
    let(:bar) { Bar.create(:name => "test") }
    after(:each) do
      bar.delete
    end

    it { expect(bar).to be_persisted }
    it { expect(bar.name).to eq("test") }
    it { expect(Bar.find(bar.id)).to_not be_nil }
  end
end
