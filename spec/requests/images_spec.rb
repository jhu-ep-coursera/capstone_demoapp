require 'rails_helper'

RSpec.describe "Images", type: :request do
  include_context "db_cleanup_each"
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  context "quick API check" do
    let!(:user) { login account }

    it_should_behave_like "resource index", :image
    it_should_behave_like "show resource", :image
    it_should_behave_like "create resource", :image
    it_should_behave_like "modifiable resource", :image
  end
end
