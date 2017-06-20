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
