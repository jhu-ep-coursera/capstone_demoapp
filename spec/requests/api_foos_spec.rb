require 'rails_helper'

RSpec.describe "Foo API", type: :request do
  include_context "db_cleanup_each", :transaction

  context "GET /api/foos" do
    it "works! (now write some real specs)" do
      get foos_path
      expect(response).to have_http_status(:ok)
    end
  end
end
