require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "Geocodes", type: :feature, js: true do
  include_context "db_cleanup"
  include SubjectsUiHelper
  let(:user) { create_user }
  let(:address) { FactoryGirl.build(:postal_address,:jhu) }

  describe "Image position" do
    it "displays image location" do
      image=FactoryGirl.create(:image)
      visit_image image
      expect(page).to have_css("sd-image-editor .image-location span.lng",:text=>image.lng)
      expect(page).to have_css("sd-image-editor .image-location span.lat",:text=>image.lat)
    end

    it "geocodes address" do
      login user
      visit_images

      typed_text="#{address.street_address}, #{address.city}"
      within("sd-image-editor .image-form .image-geocode") do
        fill_in("image-address", with:typed_text)
        expect(page).to have_field("image-address",:with=>typed_text)
      end    

      find("sd-image-editor").click  #click away from field
      using_wait_time 10 do
        expect(page).to have_css("sd-image-editor .image-location span.lng", text:/.+/)
        expect(page).to have_css("sd-image-editor .image-location span.lat", text:/.+/)
      end

      expect(cloc=CachedLocation.by_address(typed_text).first).to_not be_nil
      within("sd-image-editor .image-form") do
        expect(page).to have_css(".image-geocode .formatted_address", text:cloc.location[:formatted_address])
        expect(page).to have_css(".image-location span.lng",:text=>cloc.location[:position][:lng])
        expect(page).to have_css(".image-location span.lat",:text=>cloc.location[:position][:lat])
      end
    end

    it "assigns image location" do
      image=FactoryGirl.create(:image, :with_roles, 
                                       :creator_id=>user[:id],
                                       :position=>nil)
      login user
      visit_image image
      expect(page).to have_no_css(".image-location span")
      find_button("Clear Image")

      #update Image with geocoded location
      typed_text="#{address.street_address}, #{address.city}"
      within(".image-geocode") do
        fill_in("image-address", with:typed_text)
      end    
      find("sd-image-editor").click   #find somewhere to click
      using_wait_time 10 do
        expect(page).to have_css(".image-location span.lng", text:/.+/)
        expect(page).to have_css(".image-location span.lat", text:/.+/)
      end
      click_button("Update Image")
      expect(page).to have_no_button("Update Image")

      #refresh the display to verify value stuck
      logout
      Capybara.reset_sessions!  #cleared up error re-visiting page in docker
      visit_image image
      expect(cloc=CachedLocation.by_address(typed_text).first).to_not be_nil
      using_wait_time 5 do
        expect(page).to have_css(".image-location span.lng",
                                 :text=>cloc.location[:position][:lng])
        expect(page).to have_css(".image-location span.lat",
                                 :text=>cloc.location[:position][:lat])
      end
    end
  end

  describe "current origin" do
    let(:search_address)   { "#{address.street_address}, #{address.city}" }
    before(:each) do
      visit ui_path
      expect(page).to have_no_css("span.current-origin")
    end

    context "identifies origin by address" do
      it "has form that requires lookup address" do
        expect(page).to have_button("lookup-address",:disabled=>true)
        fill_in("address-search", :with=>search_address)
        expect(page).to have_button("lookup-address",:disabled=>false)
      end

      it "displays geocoded address" do
        fill_in("address-search", :with=>search_address)
        click_button("lookup-address")
        using_wait_time 5 do
          expect(page).to have_css("span.current-origin", :text=>/.+/)
          expect(cloc=CachedLocation.by_address(search_address).first).to_not be_nil
          resolvedAddress=cloc.location[:formatted_address]
          expect(page).to have_css("span.current-origin", :text=>resolvedAddress)
        end
      end
    end

    it "identifies origin by current location" do
      if Capybara.javascript_driver==:poltergeist && page.has_no_css?("button[name='my-position']")
        pending "poltergeist does not support $window.navigator"
      end

      expect(page).to have_css("span.current-origin", :text=>"", :visible=>false)
      find("form[name='select_origin'] [title='my-position']").click
      using_wait_time 5 do
        expect(page).to have_css("span.current-origin", :text=>/.+/)
      end
    end

    it "specifies distance limit" do
      expect(page).to_not have_css("form[name='distance_limit']")

      fill_in("address-search", :with=>search_address)
      click_button("lookup-address")
      using_wait_time 10 do
        expect(page).to have_css("span.current-origin", :text=>/.+/)
      end

      expect(page).to have_css("form[name='distance_limit']")
      within("form[name='distance_limit']") do
        fill_in("distance-limit", :with=>5)
      end
    end
  end
end
