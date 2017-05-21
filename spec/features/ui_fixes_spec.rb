require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "UI_fixes", type: :feature, js: true do
  include_context "db_cleanup"
  include SubjectsUiHelper


  describe "Image viewer" do
    it "hides switches" do
      visit "#{ui_path}/#/things/"
      expect(page).to have_css("sd-image-viewer .ng-hide", :visible=>false)
      expect(page).to have_css("sd-image-viewer .ng-hide", :visible=>false)
    end
  end

  describe "Things" do
    it "displays text" do
      visit "#{ui_path}/#/things/"
      expect(page).to have_content("Log in to see the list of things. It is visible only to members of things (certain users).")
    end


   context "logged in" do

    let(:user) { create_user }

    it "hides when logged in" do
      visit "#{ui_path}/#/things/"
      login user
      expect(page).to have_no_content("Log in to see the list of things. It is visible only to members of things (certain users).")
    end
   end


    it "not displays on sole" do
      visit "#{ui_path}/#/things/1"
      expect(page).to have_no_content("Log in to see the list of things. It is visible only to members of things (certain users).")
    end

  end

 # I don't think that we really need to test a style
#  describe "Navbar" do
#    it "has 0 margins" do
#      visit "/"
#      expect(page).to have_css(".navbar-form")
#    end
#  end

  describe "Sign Up" do
    it "shows the form" do
      visit "#{ui_path}/#/signup"
      expect(page).to have_css("#signup-form")
      expect(page).to have_no_content("It seems you are already logged in!")
    end

   context "logged in" do

    let(:user) { create_user }

    it "shows the text" do
      visit "#{ui_path}/#/signup"
      login user
      expect(page).to have_content("It seems you are already logged in!")
      expect(page).to have_no_css("#signup-form")
    end
   end


  end

end
