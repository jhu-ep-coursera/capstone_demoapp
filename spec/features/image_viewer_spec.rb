require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "ImageViewer", type: :feature, js:true do
  include_context "db_cleanup"
  include SubjectsUiHelper

  let(:originator) { apply_originator(create_user, Thing) }
  let(:organizer) { originator }
  let(:thing) { Thing.first }
  let(:images) { thing.thing_images.prioritized }
  let(:image) { thing.thing_images.primary.image }
  before(:each) do
    unless Thing.exists?
      t=FactoryGirl.create(:thing,:with_roles, :with_image, 
                         originator_id:originator[:id],
                         image_count:3)
      t.thing_images.each_with_index {|ti,idx| ti.priority=idx; ti.save}
    else
      apply_organizer(originator, Thing.first)
    end
    visit_thing thing
    logout
  end

  #making image list only accessible to organizer
  context "image access" do
    it "displays thing-images for organizer" do
      login organizer
      expect(page).to have_css("sd-image-viewer")
      expect(page).to have_css("div.thing-images", :wait=>5)
    end

    it "does not display thing-images for non-organizer" do
      expect(page).to have_css("sd-image-viewer")
      expect(page).to have_no_css("div.thing-images")
    end
  end

  context "display image" do
    it "displays image content" do
      within("sd-image-viewer .image-items") do
        expect(page).to have_css("img[src*='#{image_content_path(image)}']")
      end
    end

    it "displays image caption on click" do
      within("sd-image-viewer .image-items") do
        find("span.caption", visible:false).click
        expect(page).to have_css("span.caption", text:image.caption)
      end
    end

    it "navigates to image on click" do
      #click on the goto image link
      within("sd-image-viewer .image-items") do
        find("span.image-browse", visible:false).click
      end

      using_wait_time 15 do
        #navigates to image page
        expect(page).to have_no_css("h3",text:"Things")
        expect(page).to have_css("h3",text:"Images")
      end
    end
  end

  context "display images" do
    it "can display next image" do
      within("sd-image-viewer") do
        within(".image-items") do
          find("span.caption", visible:false).click
          expect(page).to have_css("span.caption", text:images[0].image.caption)
        end

        [1,2,0].each do |idx| 
          #go right
          find("span.glyphicon-chevron-right", visible:false).click
          within(".image-items") do
            #verify we advanced to the correct Image
            find("span.caption", visible:false).click
            using_wait_time 5 do
              expect(page).to have_css("span.caption", text:images[idx].image.caption)
            end
          end
        end
      end
    end

    it "can display previous image" do
      within("sd-image-viewer") do
        within(".image-items") do
          find("span.caption", visible:false).click
          expect(page).to have_css("span.caption", text:images[0].image.caption)
        end

        [2,1,0].each do |idx| 
          #go right
          find("span.glyphicon-chevron-left", visible:false).click
          within(".image-items") do
            #verify we advanced to the correct Image
            find("span.caption", visible:false).click
            using_wait_time 5 do
              expect(page).to have_css("span.caption", text:images[idx].image.caption)
            end
          end
        end
      end
    end
  end

  context "display sizes" do
    it "uses an image content size query" do
      within("sd-image-viewer .image-items") do
        width_query =page.first("img[src*='width=']")!=nil
        height_query=page.first("img[src*='height=']")!=nil
        expect(width_query || height_query).to be true
      end
    end
  end

end
