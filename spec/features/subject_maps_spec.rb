require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'
require_relative '../support/image_content_helper.rb'

RSpec.feature "SubjectMaps", type: :feature, js:true do
  include_context "db_cleanup"
  include SubjectsUiHelper
  let(:member)        { @member }
  let(:geocoder)      { GeocoderCache.new(Geocoder.new) }
  let(:origin)        { 
    FactoryGirl.build(:location).tap {|loc|
      pos=geocoder.geocode(loc.formatted_address)[0][:position]
      loc.position=Point.new(pos[:lng],pos[:lat])
    }
  }
  let(:true_orphan_images) { Image.where.not(:id=>ThingImage.pluck(:image_id)) }
  let(:secondaries)   { ThingImage.where.not(:thing_id=>ThingImage.where(:priority=>0)) }
  let(:things)        { ThingImage.within_range(origin.position).with_name.things }
  let(:images)        { ThingImage.within_range(origin.position).with_caption }
  before(:all) do
    @member=create_user
  end
  before(:each) do
    unless Thing.exists?
      populate_subjects
      puts "database populated"
    end
    visit "#{ui_path}/#/"
    set_origin origin.formatted_address
    visit "#{ui_path}/#/subjects"
    subjects_map_loaded!
  end
  before(:each) do 
    #page.driver.browser.navigate.refresh
      #need to randomize the search string to get a cache miss to start each test
      #when tests are shorter than the value in the Cache-Control header
#    origin.address.street_address="#{Random.new.rand(4000)} North Charles Street"
#    origin.formatted_address=origin.address.full_address
#    set_origin origin.formatted_address
#    using_wait_time 5 do
#      things.each {|ti| expect(page).to have_css("ul.things span.name", :text=>ti.thing_name) }
#    end
  end

  def click_marker title, idx=0
    search="div[title='#{title}']"
    #actually - the straight javascript solution works for all drivers
    #just showing alternate approach
    if Capybara.javascript_driver == :poltergeist
      all(search, minimum:idx+1)[idx].trigger('click');
    else
      array=all(search, minimum:idx+1).size > 1 ? "[#{idx}]" : ""
      script="$('div#map').find(\"#{search}\")#{array}.click()"
      #puts script
      page.execute_script(script)
    end
  end

  def find_marker_infowindow ti
    search="div[title='#{ti.thing.name}']"
    expect(page).to have_css(search, :wait=>10)
    all(search).each_with_index do |node, idx|
      previous_id=nil
      ti_id=nil
      found=false
      begin #keep clicking until found or getting same result
        click_marker ti.thing.name, idx
        if page.has_css?("div.thing-marker-info span.ti_id", text:ti.id, visible:false)
          found=true
        else
          previous_id=ti_id
          ti_id=page.find("div.thing-marker-info span.ti_id", visible:false).text.to_i
          #puts "ti_id=#{ti_id}, previous_id=#{previous_id}, looking for=#{ti.id}"
        end
      end until found || (previous_id && ti_id == previous_id)
      break if found
    end
    link_id=page.find("div.thing-marker-info span.ti_id", text:ti.id, visible:false)
    link_id.find(:xpath,"../..")
  end

  def find_image_marker_infowindow image
    search="div[title='#{image.caption}']"
    expect(page).to have_css(search)
    all(search).size.times do |idx|
      click_marker image.caption, idx
      if page.has_css?("div.image-marker-info span.image_id", text:image.id, visible:false)
        break
      end
    end
    link_id=page.find("div.image-marker-info span.image_id", text:image.id, visible:false)
    link_id.find(:xpath,"../..")
  end


  describe "displays map" do
    it "displays map in tab" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div.tab-content sd-tab[label='Map']") do
          expect(page).to have_css("sd-current-subjects-map")
          expect(page).to have_css("sd-current-subjects-map div#map")
          expect(page).to have_css("sd-current-subjects-map div#map > div")
        end
      end
    end
  end

  describe "displays markers" do
    it "displays origin marker" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          expect(page).to have_css("div[title='origin']")
          expect(page).to have_css("img[src*='marker-red']")
        end
      end
    end

    it "displays primary thing markers" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          using_wait_time 5 do
            things.each do |ti|
              expect(page).to have_css("div[title='#{ti.thing_name}']")
              expect(page).to have_css("img[src*='marker-black']")
            end
          end
        end
      end
    end

    it "displays secondary markers" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          using_wait_time 5 do
            secondaries.each do |ti|
              expect(page).to have_css("div[title='#{ti.thing.name}']")
              expect(page).to have_css("img[src*='marker-grey']")
            end
          end
        end
      end
    end

    it "displays orphan markers" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          using_wait_time 5 do
            true_orphan_images.each do |image|
              expect(page).to have_css("div[title='#{image.caption}']")
              expect(page).to have_css("img[src*='marker-yellow']")
            end
          end
        end
      end
    end

  end

  describe "displays info windows" do
    it "displays current origin location" do
      set_origin origin.formatted_address
      cloc=CachedLocation.by_address(origin.formatted_address).first.location
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          click_marker "origin"
          #save_and_open_page
          #save_and_open_screenshot
          expect(page).to have_css("div.full_address", text:cloc[:formatted_address],wait:10)
          expect(page).to have_css("div.position span.lng", text:cloc[:position][:lng])
          expect(page).to have_css("div.position span.lat", text:cloc[:position][:lat])
        end
      end
    end


    it "displays things image and info" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          ThingImage.all.each do |ti|
            within(find_marker_infowindow(ti)) do
              expect(page).to have_css("span.thing-name", text:ti.thing.name, wait:10)
              if ti.image.caption
                expect(page).to have_css("span.image-caption", text:"#{ti.image.caption}")
              else 
                expect(page).to have_no_css("span.image-caption") 
              end
              expect(page).to have_css("img[src*='images/#{ti.image.id}/content?width=200']");
            end
          end
        end
      end
    end

    it "displays orphan image and info" do
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          true_orphan_images.all.each do |image|
            within(find_image_marker_infowindow(image)) do
              if image.caption
                expect(page).to have_css("span.image-caption", text:"#{image.caption}", wait:10)
              else 
                expect(page).to have_no_css("span.image-caption", wait:10) 
              end
              expect(page).to have_css("img[src*='images/#{image.id}/content?width=200']", wait:10);
            end
          end
        end
      end
    end

    it "displays distance when origin set" do
      #origin already set
      expect(page).to have_css("span.distance",:text=>/miles/,:visible=>false)
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          #save_and_open_screenshot
          ThingImage.all.each do |ti|
            distance=ti.image.distance_from(origin.position).round(1)
            within(find_marker_infowindow(ti)) do
              expect(page).to have_css("span.distance", text:"(#{distance} mi)", wait:10)
            end
          end
          true_orphan_images.all.each do |image|
            distance=image.distance_from(origin.position).round(1)
            #save_and_open_screenshot
            within(find_image_marker_infowindow(image)) do
              expect(page).to have_css("span.distance", text:"(#{distance} mi)", wait:10)
            end
          end
        end
      end
    end
  end

  describe "subject synchronization" do
    it "displays InfoWindow for current Image" do
      Image.all.each do |image|
        select_image image.id
        within("sd-area[label='Map']") do
          find("div.tabs-pane ul li a", :text=>"Map").click
          within("div#map") do
            expect(page).to have_css("span.image_id", text:image.id, visible:false)
          end
        end
      end
    end

    it "displays InfoWindow for current Thing" do
      things.all.each do |ti|
        select_thing ti.thing_id
        within("sd-area[label='Map']") do
          find("div.tabs-pane ul li a", :text=>"Map").click
          within("div#map") do
            expect(page).to have_css("span.thing_id", text:ti.thing_id, visible:false)
            expect(page).to have_css("span.image_id", text:ti.image_id, visible:false)
          end
        end
      end
    end

    def select_thing_marker ti
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          find_marker_infowindow(ti)
        end
      end
    end
    def select_image_marker image
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          find_image_marker_infowindow(image)
        end
      end
    end

    it "updates current subject with local selection" do
      primary_tis = things.pluck(:thing_id)
      images.each do |ti|
        if ti.thing_id
          select_thing_marker ti
        else 
          select_image_marker ti.image
        end
        if primary_tis.include?(ti.thing_id)
          expect(get_current_thing_id).to eq(ti.thing_id)
        else
          has_no_current_thing_id
        end
      end
    end

    def check_map_origin cloc
      within("sd-area[label='Map']") do
        find("div.tabs-pane ul li a", :text=>"Map").click
        within("div#map") do
          click_marker "origin"
          expect(page).to have_css("div.full_address", text:cloc[:formatted_address])
          expect(page).to have_css("div.position span.lng", text:cloc[:position][:lng])
          expect(page).to have_css("div.position span.lat", text:cloc[:position][:lat])
        end
      end
    end

    it "updates map with current origin" do
      cloc=CachedLocation.by_address(origin.formatted_address).first.location
      check_map_origin cloc

      new_address="Pratt Street, Baltimore MD"
      set_origin new_address
      cloc=CachedLocation.by_address(new_address).first.location
      check_map_origin cloc
    end
  end
end
