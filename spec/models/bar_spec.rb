require 'rails_helper'

require 'mongo'
Mongo::Logger.logger.level = ::Logger::DEBUG

describe Bar, :type=>:model, :orm=>:mongoid do
  before(:all) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  context Bar do
    it { is_expected.to have_field(:name).of_type(String).with_default_value_of(nil) }
  end

  context "created Bar (let)" do
    let(:bar) { Bar.create(:name => "test") }
    before(:each) do
      DatabaseCleaner.start
    end
    after(:each) do
      DatabaseCleaner.clean
    end

    it { expect(bar).to be_persisted }
    it { expect(bar.name).to eq("test") }
    it { expect(Bar.find(bar.id)).to_not be_nil }
  end
end
