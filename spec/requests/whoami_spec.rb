require 'rails_helper'

RSpec.describe "WhoAmI", type: :request do
  include_context "db_cleanup_each"
  let(:account) { signup FactoryGirl.attributes_for(:user) }

  def whoami user
    jget authn_whoami_path
    #pp parsed_body
    expect(response).to have_http_status(:ok)
    payload=parsed_body
    if user
      expect(payload).to include("id"=>user["id"])
      expect(payload).to include("email"=>user["email"])
      expect(payload).to include("user_roles")
      payload["user_roles"]
    else 
      expect(payload).to_not include("id")
      expect(payload).to_not include("email")
      expect(payload).to_not include("user_roles")
      []
    end
  end

  shared_examples "no roles" do
    it "" do
      user_roles=whoami(user)
      expect(user_roles).to be_empty
    end
  end

  context "anonymous" do
    let(:user)    { nil }
    before(:each) { logout nil }
    it_should_behave_like "no roles"
  end
  context "authenticated" do
    let(:user)    { login account }
    it_should_behave_like "no roles"
  end
  context "member" do
    let(:user)    { apply_member(login(account), FactoryGirl.create(:thing)) }
    it_should_behave_like "no roles"
  end
  context "originator" do
    let(:user) { apply_originator(login(account), Thing) }
    it "has originator role" do
      apply_member(user, FactoryGirl.create(:thing))
      user_roles=whoami(user)
      expect(user_roles.size).to eq(1)
      expect(user_roles[0]).to include("role_name"=>Role::ORIGINATOR,
                                       "resource"=>Thing.model_name)
    end
  end
  context "admin" do
    let(:user) { apply_admin(login(account)) }
    it "has admin role" do
      user_roles=whoami(user)
      expect(user_roles.size).to eq(1)
      expect(user_roles[0]).to include("role_name"=>Role::ADMIN)
      expect(user_roles[0]).to_not include("resource")
    end
  end
  context "originator_admin" do
    let(:user) { apply_admin(apply_originator(login(account),Thing)) }
    it "has originator and admin role" do
      user_roles=whoami(user)
      expect(user_roles.size).to eq(2)
      admin_role=nil
      originator_role=nil
      user_roles.each do |role|
        case role["role_name"]
        when Role::ADMIN
          admin_role=role
        when Role::ORIGINATOR
          originator_role=role
        end
      end
      expect(admin_role).to_not be_nil
      expect(originator_role).to_not be nil
      expect(originator_role["resource"]).to eq(Thing.model_name)
    end
  end
end
