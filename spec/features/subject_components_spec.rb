require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'
require_relative '../support/image_content_helper.rb'

RSpec.feature "SubjectComponents", type: :feature, js: true do
  include_context "db_cleanup"
  include SubjectsUiHelper

  let(:member)        { @member }
  let(:origin)        { FactoryGirl.build(:location) }
  let(:true_orphan_images) { Image.where.not(:id=>ThingImage.pluck(:image_id)) }
  let(:orphan_images) { ThingImage.where.not(:thing_id=>ThingImage.where(:priority=>0).pluck(:thing_id)) }
  let(:things)        { ThingImage.within_range(origin.position).things }
  let(:images)        { ThingImage.within_range(origin.position) }
  before(:all) do
    @member=create_user
  end
  before(:each) do
    unless Thing.exists?
      populate_subjects
    end
    visit "#{ui_path}/#/subjects"
  end

  def get_distance node
    within(node) do 
      text=find("span.distance").text
      expect(distance=/(\d+\.?\d+)/.match(text)[1]).to_not be_nil
      distance=distance.to_f
    end
  end

  def get_item_nodes area, type, size
    name=type.to_s.downcase.pluralize
    within("sd-area[label='#{area}']") do
      find("div.tabs-pane ul li a", :text=>"#{name.camelize.pluralize}").click
      expect(page).to have_css("ul.#{name} li:nth-child(#{size})")
      page.all("ul.#{name} li", count: size)
    end
  end

  describe "images list view" do
    it "has Image list components" do
      ["Subjects","Map"].each do |area|
        within("sd-area[label='#{area}']") do
          find("div.tabs-pane ul li a", :text=>"Images").click
          expect(page).to have_css("div.tab-content sd-tab[label='Images']")
          within("div.tab-content sd-tab[label='Images']") do
            expect(page).to have_css("ul.images")
          end
        end
      end
    end

    it "displays images and captions" do
      expect(page).to have_no_css("span.current-origin", :text=>/.+/)
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Images").click
        within("div.tab-content sd-tab[label='Images']") do
          expect(page).to have_css("ul.images li:nth-child(#{images.size})")
          page.all("ul.images li", count: images.size).each_with_index do |node, idx|
            node=find("ul.images li:nth-child(#{idx+1})")
            within(node) do
              expect(page).to have_css("img")
              expect(page).to have_css("span.caption")
              expect(page).to have_no_css("span.distance")
            end
          end
        end
      end
    end

    it "displays id and Thing info when assigned" do
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Images").click
        within("div.tab-content sd-tab[label='Images']") do
          expect(page).to have_css("ul.images li:nth-child(#{images.size})")
          things.each do |ti|
            image_ids=page.all("ul.images span.image_id",text:ti.image_id, visible:false)
            expect(image_ids.size).to be > 0
            image_ids.each do |id_node|
              within(id_node.find(:xpath,"..")) do
                expect(page).to have_css("span.thing_name")
                expect(page).to have_css("span.thing_id", visible:false)
                expect(page).to have_no_css("span.thing_id")
              end
            end
          end
        end
      end
    end

    it "displays id and no Thing info when orphan" do
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Images").click
        within("div.tab-content sd-tab[label='Images']") do
          true_orphan_images.each do |orphan|
            id_node=find("ul.images span.image_id",text:orphan.id, visible:false)
            within(id_node.find(:xpath,"..")) do
              expect(page).to have_no_css("span.thing_name")
              expect(page).to have_no_css("span.thing_id", visible:false)
            end
          end
        end
      end
    end

    it "displays image distances when origin set" do
      set_origin origin.formatted_address
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Images").click
        expect(page).to have_css("ul.images li:nth-child(#{images.size})")
        page.all("ul.images li", count:images.size).each_with_index do |node, idx|
          #counter Capybara::Poltergeist::ObsoleteNode:
          node=page.find("ul.images li:nth-child(#{idx+1})")
          within(node) do          
            expect(page).to have_css("img")
            expect(page).to have_css("span.caption")
            expect(page).to have_css("span.distance")
            expect(page).to have_css("span.image_id",visible:false)
            expect(page).to have_no_css("span.distance", :text=>/\.\d{2,} miles/)
            expect(page).to have_css("span.distance", :text=>/(\d+\.\d{0,1} miles)/)
          end
        end
      end
    end

    it "ordered Images from closest to farthest" do
      set_origin origin.formatted_address
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Images").click
        expect(page).to have_css("ul.images li:nth-child(#{images.size})")

        previous_distance=-1.0
        page.all("ul.images li", count: images.size).each_with_index do |node, idx|
          #counter Capybara::Poltergeist::ObsoleteNode:
          node=page.find("ul.images li:nth-child(#{idx+1})")
          distance=get_distance node
          expect(distance).to be >= previous_distance
          previous_distance = distance
        end
      end
    end

    it "sets shared current subject with local Image list selection" do
      image_list=get_item_nodes("Subjects", :image, images.size)

      previous_image=nil
      image_list.each do |image|
        within(image) do
          wait_until(5) {find("a").click; image[:class].include?("selected")}
          expect(previous_image[:class]).to_not include("selected") if previous_image
          previous_image = image
        end
      end
    end

    it "changes local Image list selection to current selection" do
      image_list=get_item_nodes("Subjects", :image, images.size)
      find("sd-area[label='Map'] div.tabs-pane ul li a", :text=>"Images").click

      image_list.each do |image|
        within(image) do
          wait_until(5) {find("a").click; image[:class].include?("selected")}
        end
        within("sd-area[label='Map']") do
          caption=find("div.tabs-pane ul li.selected").text
          expect(caption).to eq(image.text)
        end
      end
    end
  end

  describe "things list view" do
    it "has Things list components" do
      ["Subjects","Map"].each do |area|
        within("sd-area[label='#{area}']") do
          find("div.tabs-pane ul li a", :text=>"Things").click
          expect(page).to have_css("div.tab-content sd-tab[label='Things']")
          within("div.tab-content sd-tab[label='Things']") do
            expect(page).to have_css("ul.things")
          end
        end
      end
    end

    it "displays id, image, name, and Image info" do
      expect(page).to have_no_css("span.current-origin", :text=>/.+/)
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Things").click
        within("div.tab-content sd-tab[label='Things']") do
          expect(page).to have_css("ul.things li:nth-child(#{things.size})")
          page.all("ul.things li", count:things.size).each_with_index do |node, idx|
            node=find("ul.things li:nth-child(#{idx+1})")
            within(node) do
              expect(page).to have_css("img")
              expect(page).to have_css("span.name")
              expect(page).to have_css("span.thing_id", visible:false)
              expect(page).to have_css("span.image_id", visible:false)
              expect(page).to have_no_css("span.distance")
            end
          end
        end
      end
    end

    it "displays thing distances when origin set" do
      set_origin origin.formatted_address
      within("sd-area[label='Subjects']") do
        find("div.tabs-pane ul li a", :text=>"Things").click
        expect(page).to have_css("ul.things li:nth-child(#{things.size})")
        page.all("ul.things li", count: things.size).each_with_index do |node, idx|
          #counter Capybara::Poltergeist::ObsoleteNode
          node=page.find("ul.things li:nth-child(#{idx+1})")
          within(node) do
            expect(page).to have_css("img")
            expect(page).to have_css("span.name")
            expect(page).to have_css("span.distance")
            expect(page).to have_no_css("span.distance", :text=>/\.\d{2,} miles/)
            expect(page).to have_css("span.distance", :text=>/(\d+\.\d{0,1} miles)/)
          end
        end
      end
    end

    it "ordered Things from closest to farthest" do
        set_origin origin.formatted_address
        within("sd-area[label='Subjects']") do
          find("div.tabs-pane ul li a", :text=>"Things").click
          expect(page).to have_css("ul.things li:nth-child(#{things.size})")

          previous_distance=-1.0
          page.all("ul.things li", count: things.size).each_with_index do |node, idx|
            #counter Capybara::Poltergeist::ObsoleteNode:
            node=page.find("ul.things li:nth-child(#{idx+1})")
            distance=get_distance node
            expect(distance).to be >= previous_distance
            previous_distance = distance
          end
        end
      end
      it "sets shared current subject with local Thing list selection" do
        thing_list=get_item_nodes("Subjects", :thing, things.size)

        previous_thing=nil
        thing_list.each do |thing|
          within(thing) do
            find("a").click
            wait_until {thing[:class].include?("selected")}
            expect(previous_thing[:class]).to_not include("selected") if previous_thing
            previous_thing = thing
          end
        end
      end

      it "changes local Thing list selection to current selection" do
        thing_list=get_item_nodes("Subjects", :thing, things.size)
        find("sd-area[label='Map'] div.tabs-pane ul li a", :text=>"Things").click

        thing_list.each do |thing|
          within(thing) do
            find("a").click
            wait_until { thing[:class].include?("selected") }
          end
          within("sd-area[label='Map']") do
            name=find("div.tabs-pane ul li.selected").text
            expect(name).to eq(thing.text)
          end
        end
      end
    end


    describe "image and thing synchronization" do

      it "unselects Thing for orphan Image" do
        orphan_images.each do |orphan|
          select_thing things.sample.thing_id
          select_image orphan.image_id, orphan.thing_id
          within("sd-area[label='Map']") do #no Thing should be selected
            find("div.tabs-pane ul li a", :text=>"Things").click
            expect(page).to have_no_css("ul.things li.selected")
          end
        end
      end

      it "selects related Thing for Image" do
        things.each do |ti|  #displayed Image and Thing must be related
          wait_until(5) do
            select_image(ti.image_id)
            thing_id = get_current_thing_id()
            expect(thing_id).to_not be_nil
            ThingImage.where(thing_id:thing_id, image_id:ti.image_id).exists?
          end
        end
      end

      it "selects primary Image for Thing" do
        things.each do |ti|
          select_thing ti.thing_id
          expect(get_current_image_id).to eq(ti.thing
                                               .thing_images
                                               .primary
                                               .image_id)
        end
      end
    end

    describe "image view" do
      it "has Image viewer components" do
        ["Details", "Map"].each do |area|
          within("sd-area[label='#{area}']") do
            find("div.tabs-pane ul li a", :text=>/^Image$/).click
            expect(page).to have_css("div.tab-content sd-tab[label='Image']")
            within("div.tab-content sd-tab[label='Image']") do
              expect(page).to have_css("sd-image-viewer")
            end
          end
        end
      end

      it "displays image content" do
        within("sd-area[label='Details']") do
          find("div.tabs-pane ul li a", :text=>/^Image$/).click
          within("div.tab-content sd-tab[label='Image']") do
            expect(page).to have_css("div.image-items:nth-child(#{images.size})",
                                     visible:false)
            within("div.image-items") do
              expect(page).to have_css("img")
              expect(page).to have_css("span.caption", visible:false)
              src=find("img")[:src]
              expect(width=/width=(\d+)/.match(src)[1]).to_not be_nil
              expect(width.to_i).to be >= 400
              expect(page).to have_css("span.image_id", visible:false)
              expect(page).to have_no_css("span.image_id")
            end
            within("div.image-area") do
              expect(page).to have_css("span.glyphicon-chevron-left", visible:false)
              expect(page).to have_css("span.glyphicon-chevron-right", visible:false)
            end
          end
        end
      end

      it "displays current Image" do
        images.each do |ti|
          select_image ti.image_id, ti.thing_id
          within("sd-area[label='Details']") do
            find("div.tabs-pane ul li a", :text=>/^Image$/).click
            within("div.tab-content sd-tab[label='Image'] div.image-items") do
              expect(page).to have_css("span.image_id", visible:false, text:ti.image_id, :wait=>10)
            end
          end
        end
      end

      it "can go to next image" do
        ti = images.sample
        select_image ti.image_id, ti.thing_id

        images.size.times do |idx|
          viewer_image_id=nil
          within("sd-area[label='Details']") do
            find("div.tabs-pane ul li a", :text=>/^Image$/).click
            within("div.tab-content sd-tab[label='Image']") do
              within("div.image-area") do
                find("span.glyphicon-chevron-right", visible:false).click
              end
              sleep 0.1 #give image (could be same image) chance to appear
              within("div.image-items") do
                viewer_image_id=find("span.image_id", visible:false).text(:all)
              end
            end
          end

          expect(get_current_image_id).to eq(viewer_image_id.to_i)
        end
      end

      it "can go to previous image" do
        ti = images.sample
        select_image ti.image_id, ti.thing_id

        images.size.times do |idx|
          viewer_image_id=nil
          within("sd-area[label='Details']") do
            find("div.tabs-pane ul li a", :text=>/^Image$/).click
            within("div.tab-content sd-tab[label='Image']") do
              within("div.image-area") do
                find("span.glyphicon-chevron-left", visible:false).click
              end
              sleep 0.1 #give image (could be same image) chance to appear
              within("div.image-items") do
                viewer_image_id=find("span.image_id", visible:false).text(:all)
              end
            end
          end

          expect(get_current_image_id).to eq(viewer_image_id.to_i)
        end
      end
    end

    describe "thing info" do
      before(:each) do
        login member
      end

      it "has Thing info components" do
        ["Details", "Map"].each do |area|
          within("sd-area[label='#{area}']") do
            find("div.tabs-pane ul li a", :text=>/^Thing$/).click
            expect(page).to have_css("div.tab-content sd-tab[label='Thing']")
            within("div.tab-content sd-tab[label='Thing']") do
              expect(page).to have_css("sd-current-thing-info")
              expect(page).to have_css("div.thing-info")
            end
          end
        end
      end

      it "displays Thing info" do
        selected_thing = Thing.first
        select_thing selected_thing.id
        within("sd-area[label='Details']") do
          find("div.tabs-pane ul li a", :text=>/^Thing$/).click
          within("div.tab-content sd-tab[label='Thing']") do
            within("div.thing-info") do
              expect(page).to have_css("h4", text:selected_thing.name)
              expect(page).to have_css("span.thing_id", visible:false)
              expect(page).to have_css("span.glyphicon-chevron-left", visible:false)
              expect(page).to have_css("span.glyphicon-chevron-right", visible:false)
              expect(page).to have_no_css("div.distance")
              expect(page).to have_css("div.description",text:selected_thing.description)
              expect(page).to have_css("div.notes",text:selected_thing.notes)
            end
          end
        end
      end

      it "displays Thing distance when origin set" do
      set_origin origin.formatted_address
      within("sd-area[label='Details']") do
        find("div.tabs-pane ul li a", :text=>/^Thing$/).click
        within("div.tab-content sd-tab[label='Thing']") do
          within("div.thing-info") do
            expect(page).to have_css("div.distance")
            expect(page).to have_no_css("div.distance", :text=>/\.\d{2,} miles/)
            expect(page).to have_css("div.distance", :text=>/(\d+\.\d{1} miles)/)
          end
        end
      end
    end

    def check_info_thing_id thing_id
      within("sd-area[label='Details']") do
        find("div.tabs-pane ul li a", :text=>/^Thing$/).click
        within("div.tab-content sd-tab[label='Thing']") do
          within("div.thing-info") do
            expect(page).to have_css("span.thing_id",visible:false,text:thing_id,wait:10)
          end
        end
      end
    end

    it "displays current Thing info" do
      things.each do |ti|
        select_image ti.image_id, ti.thing_id
        check_info_thing_id ti.thing_id
      end
      orphan_images.each do |ti|
        select_image ti.image_id, nil
        check_info_thing_id ""
      end
    end

    def click_arrow direction
      within("sd-area[label='Details']") do
        find("div.tabs-pane ul li a", :text=>/^Thing$/).click
        within("div.tab-content sd-tab[label='Thing']") do
          within("div.thing-info") do
            find("span.glyphicon-chevron-#{direction}", visible:false).click
            info_thing_id=find("span.thing_id", visible:false).text(:all)
            info_thing_id = info_thing_id.to_i  if info_thing_id
          end
        end
      end
    end

    it "can go to next Thing" do
      ti = things.sample
      select_thing ti.thing_id

      previous_id=nil
      things.size.times do |idx|
        info_thing_id=click_arrow "right"
        expect(info_thing_id).to_not eq(previous_id)
        previous_id = info_thing_id
        expect(get_current_thing_id).to eq(info_thing_id)
      end
    end

    it "can go to previous Thing" do
      ti = things.sample
      select_thing ti.thing_id

      previous_id=nil
      things.size.times do |idx|
        info_thing_id=click_arrow "left"
        expect(info_thing_id).to_not eq(previous_id)
        previous_id = info_thing_id
        expect(get_current_thing_id).to eq(info_thing_id)
      end
    end
  end
end
