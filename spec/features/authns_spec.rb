require 'rails_helper'

RSpec.feature "Authns", type: :feature, :js=>true do

  feature "sign-up" do
    context "valid registration" do
      scenario "creates account and navigates away from signup page"
    end

    context "rejected registration" do
      scenario "account not created and stays on page"
      scenario "displays error messages"
    end

    context "invalid field" do
      scenario "bad email"
      scenario "missing password"
    end
  end

  feature "anonymous user" do
    scenario "shown login form"
  end

  feature "login" do
    context "valid user login" do
      scenario "closes form and displays current user name"
      scenario "menu shows logout option"
      scenario "can access authenticated resources"
    end

    context "invalid login" do
      scenario "error message displayed and leaves user unauthenticated"
    end
  end

  feature "logout" do
    scenario "closes form and removes user name"
    scenario "can no longer access authenticated resources"
  end
end
