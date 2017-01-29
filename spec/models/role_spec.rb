require 'rails_helper'

RSpec.describe Role, type: :model do

  context "user assigned roles" do
    # we start with an instance of a Devise user in the database
    let(:user) { FactoryGirl.create(:user) }

    it "has roles" do
      # we add two Role definitions to the Devise user
      user.roles.create(:role_name=>Role::ADMIN)
      user.roles.create(:role_name=>Role::ORIGINATOR,:mname=>"Foo")
      user.roles.create(:role_name=>Role::ORGANIZER,:mname=>"Bar", :mid=>1)
      user.roles.create(:role_name=>Role::MEMBER,:mname=>"Baz", :mid=>1)

      db_user=User.find(user.id)
      expect(db_user.has_role([Role::ADMIN])).to be true
      expect(db_user.has_role([Role::ORIGINATOR],"Bar")).to be false
      expect(db_user.has_role([Role::ORIGINATOR],"Foo")).to be true
      expect(db_user.has_role([Role::MEMBER],"Baz", 1)).to be true
    end
  end

  context "admin factory" do
    let(:admin) { FactoryGirl.build(:admin) }
    let(:db_admin) { FactoryGirl.create(:admin) }

    it "builds admin" do
      expect(admin.id).to be_nil
      admin_role=admin.roles.select {|r| r.role_name==Role::ADMIN}.first
      expect(admin_role).to have_attributes(:role_name=>Role::ADMIN, :mname=>nil)
    end
    it "creates admin" do
      db_user=User.find(db_admin.id)
      expect(db_user.has_role([Role::ADMIN],User.name)).to be true
    end
  end

  context "originator factory" do
    let(:o) { FactoryGirl.build(:originator, :mname=>User.name) }
    let(:db_o) { FactoryGirl.create(:originator, :mname=>User.name) }

    it "builds originator" do
      expect(o.id).to be_nil
      originator_role=o.roles.select {|r| r.role_name==Role::ORIGINATOR}.first
      expect(originator_role).to have_attributes(:role_name=>Role::ORIGINATOR, :mname=>User.name)
    end
    it "creates admin" do
      db_user=User.find(db_o.id)
      expect(db_user.has_role([Role::ORIGINATOR],User.name)).to be true
    end
  end
end
