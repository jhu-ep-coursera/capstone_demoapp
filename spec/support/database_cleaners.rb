require 'database_cleaner'

shared_context "db_cleanup" do |ar_strategy=:truncation|
  before(:all) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:active_record].strategy = ar_strategy
    DatabaseCleaner.clean_with(:truncation)
  end
  after(:each, :type=>feature) do
    Capybara.reset_sessions!  #cleared up some random failures
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
end

shared_context "db_scope" do
  before(:each) do
    DatabaseCleaner.start
  end
  after(:each) do
    DatabaseCleaner.clean
  end
end

shared_context "db_cleanup_each" do |ar_strategy=:truncation|
  before(:all) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:active_record].strategy = ar_strategy
    DatabaseCleaner.clean_with(:truncation)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
  before(:each) do
    DatabaseCleaner.start
  end
  after(:each) do
    Capybara.reset_sessions!  if self.class.metadata[:js] 
    #page.driver.clear_memory_cache
    DatabaseCleaner.clean
  end
end
