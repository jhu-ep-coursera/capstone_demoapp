require 'rails_helper'
require_relative '../support/subjects_ui_helper.rb'

RSpec.feature "AuthzThingImages", type: :feature, :js=>true do
  include_context "db_cleanup_each"
  include SubjectsUiHelper

  let(:admin)         { apply_admin(create_user) }
  let(:originator)    { apply_originator(create_user, Thing) }
  let(:organizer)     { originator }
  let(:member)        { create_user }
  let(:alt_member)    { create_user }
  let(:authenticated) { create_user }
  let(:thing_props)   { FactoryGirl.attributes_for(:thing) }
  let(:things)        { FactoryGirl.create_list(:thing, 3) }
  let(:things)        { FactoryGirl.create_list(:thing, 3, 
                                                :with_roles, 
                                                :originator_id=>originator[:id],
                                                :member_id=>member[:id]) }
  let(:alt_things)    { FactoryGirl.create_list(:thing, 1, 
                                                :with_roles, 
                                                :originator_id=>originator[:id],
                                                :member_id=>alt_member[:id]) }
  let(:images) { FactoryGirl.create_list(:image, 3, 
                                         :with_roles, 
                                         :creator_id=>authenticated[:id]) }
  let(:linked_thing)  { things[0] }
  let(:linked_image)  { images[0] }
  let(:thing_image) { FactoryGirl.create(:thing_image,
                                         :thing=>linked_thing,
                                         :image=>linked_image,
                                         :priority=>3,
                                         :creator_id=>member[:id]) }

  before(:each) do
    #touch these before we start
    thing_image   
    alt_things
    visit ui_path
  end

  shared_examples "can get links" do
    context "from images" do 
      before(:each) { visit_image linked_image }
      it "can view linked things for image" do
        within("sd-image-editor") do
          expect(page).to have_css("div.image-things")
          within("div.image-things") do
            expect(page).to have_css("label", :text=>"Related Things")
            expect(page).to have_css("li a", :text=>linked_thing.name)
            expect(page).to have_css("li span.thing_id", 
                                     :text=>linked_thing.id, 
                                     :visible=>false)
            expect(page).to have_no_css("li span.thing_id") #should be hidden
          end
        end
        #make sure all updates received from server before quitting
        image_editor_loaded! linked_image
      end
      it "can navigate from image to thing" do
        expect(page).to have_css("sd-image-editor")
        link_selector_args=["sd-image-editor ul.image-things span.thing_id",
                            {:text=>linked_thing.id, :visible=>false, :wait=>5}]

        #extend timeouts for an extensive amount of concurrent, async activity
        using_wait_time 5 do
          #wait for the link to show up and then click
          find(*link_selector_args).find(:xpath,"..").click
          #wait for page to react to link and switch away
          expect(page).to have_no_css(*link_selector_args)
          expect(page).to have_no_css("sd-image-editor")

          #wait for page navigated to arrive, displaying expected
          thing_editor_loaded! linked_thing
        end
      end
    end
    context "from things" do
      before(:each) { visit_thing linked_thing }
      it "can view linked images for thing" do
        expect(page).to have_css("sd-thing-editor")
        expect(page).to have_css(".thing-image-viewer label", :text=>"Related Images")
        expect(page).to have_css(".image-area img[src*='#{image_content_path(linked_image)}']",
                                :visible=>false, :wait=>5)
      end
      it "can navigate from thing to image" do
        expect(page).to have_css("sd-thing-editor")
        expect(page).to have_css(".image-area img[src*='#{image_content_path(linked_image)}']",
                                :visible=>false, :wait=>5)

        #extend timeouts for an extensive amount of concurrent, async activity
        using_wait_time 20 do
          #wait for the link to show up and then click
          page.find("span.image-browse[href*='images/#{linked_image.id}']",:visible=>false).click
        end

        #wait for page to react to link and switch away
        expect(page).to have_no_css("sd-thing-editor")

        #wait for page navigated to arrive, displaying expected
        image_editor_loaded! linked_image
      end
    end
  end

  #we mean links to specific things
  shared_examples "can create links" do
    before(:each) { visit_image linked_image }

    it "can get linkable things for image" do
      linkables=get_linkables(linked_image)
      # verify page contains option to select unlinked things
      within("sd-image-editor .image-form .linkable-things") do
        expect(page).to have_css(".link-things select option", :count=>linkables.size, :wait=>5)
        (1..2).each do |i|
          expect(page).to have_css(".link-things select option", :text=>things[i].name)
          expect(page).to have_css(".link-things select option[value='#{things[i].id}']")
        end
        # verify page does not contain option to already linked things
        expect(page).to have_no_css(".link-things select option[value='#{linked_thing.id}']")
      end
      #make sure page finishes loading before ending test
      image_editor_loaded! linked_image, linkables.size
    end

    it "can create link image to things" do
      within("sd-image-editor .image-form") do
        #verify new thing not in linked things
        expect(page).to have_css("ul.image-things li a", :text=>linked_thing.name,:wait=>5)
        expect(page).to have_no_css("ul.image-things li a", :text=>things[1].name)

        #click on option
        find(".link-things select option", :text=>things[1].name).select_option
        button=page.has_button?("Update Image") ? "Update Image" : "Link to Things"
        click_button(button)
        expect(page).to have_button(button,:disabled=>true,:wait=>5)

        #was added to linked things
        expect(page).to have_css("ul.image-things li a", :text=>linked_thing.name)
        expect(page).to have_css("ul.image-things li a", :text=>things[1].name)
        expect(page).to have_css("ul.image-things li span.thing_id", 
                                 :text=>things[1].id, :visible=>false)
      end
    end

    it "removes thing from linkables when linked" do
      linkables=get_linkables(linked_image)
      within("sd-image-editor .image-form") do
        expect(page).to have_css(".link-things select option", :count=>linkables.size, :wait=>5)
        #select one of the linkables and link to image
        using_wait_time 5 do # given extra time for related calls to complete
          find(".link-things select option", :text=>things[1].name).select_option
          #save_and_open_page
        end
        button=page.has_button?("Update Image") ? "Update Image" : "Link to Things"
        expect(page).to have_button(button,:disabled=>false)
        click_button(button)
        expect(page).to have_button(button,:disabled=>true,:wait=>5)

        #once linked, the thing should no longer show up in the linkables
        expect(page).to have_no_css(".link-things select option", :text=>things[1].name)

        #wait for async server updated to complete
        expect(page).to have_css("ul.image-things li span.thing_id", 
                                 :text=>things[1].id, :visible=>false, :wait=>5)
      end
      #try to wait for all requests to server to complete before exiting
      image_editor_loaded! linked_image, linkables.size-1
    end

    it "removes link button when no linkables" do
      linkables=get_linkables(linked_image)
      within("sd-image-editor .image-form") do
        #wait for the list to be displayed
        expect(page).to have_css(".link-things select option", :count=>linkables.size, :wait=>5)

        #select all of the expected linkables and link to image
        all(".link-things select option").each do |option|
            option.select_option
        end
        button=page.has_button?("Update Image") ? "Update Image" : "Link to Things"
        click_button(button)
        #Note ID goes away briefly during the reload(), causing these buttons to blink
        expect(page).to have_button(button,:disabled=>true,:wait=>5)

        #wait for page to update
        expect(page).to have_css("ul.image-things li span.thing_id", 
                                 :text=>things[1].id, :visible=>false, :wait=>5)
      end
    end
  end

  #we mean links to specific things
  shared_examples "cannot create link" do
    before(:each) { visit_image linked_image }
    it "shows no linkable things for image" do
      within("sd-image-editor .image-form") do
        things.each do |thing|
          expect(page).to have_no_css("select option", :text=>thing.name)
        end
      end
    end
  end

  shared_examples "can edit link" do
    before(:each) { visit_thing linked_thing }

    it "can view priority of image" do
      within("sd-thing-editor .thing-form .thing-images ul") do
        within("li", :text=>displayed_caption(linked_image)) do
          expect(page).to have_field("image-priority", :with=>thing_image.priority)
        end
      end
    end

    it "can adjust priority of image" do
      within("sd-thing-editor .thing-form") do
        new_priority=thing_image.priority==0 ? thing_image.priority - 1 : 9;
        expect(old_priority=ThingImage.find(thing_image.id).priority).to_not eq(new_priority)
        expect(page).to have_button("Update Thing", :disabled=>true)
        expect(page).to have_css("div.thing-images span.image_id",:text=>linked_image.id,
                                 :visible=>false,:wait=>5)

        #find and change the priority
        image_li=find("div.thing-images span.image_id",:text=>linked_image.id, 
                      :visible=>false).find(:xpath,"../..")
        within(image_li) do
          find_field("image-priority", :with=>old_priority, :readonly=>false)
          fill_in("image-priority", :with=>new_priority)
          find_field("image-priority", :with=>new_priority)
          expect(page).to have_css("div.glyphicon-asterisk", :wait=>5)
        end
        button = page.has_button?("Update Thing") ? "Update Thing" : "Update Image Links"
        click_button(button)
        #we need to wait for button to go away before going forward
        expect(page).to have_no_button("Update Image Links")
        #there is a flicker for this button because ID missing while image reloads
        expect(page).to have_button("Update Thing", :disabled=>true,:wait=>5)

        #verify priority displayed on the page
        within(".thing-images ul li", :text=>displayed_caption(linked_image)) do
          expect(page).to have_field("image-priority", :with=>new_priority)
        end
        #verify database has the expected value
        expect(ThingImage.find(thing_image.id).priority).to eq(new_priority)
      end
    end

    it "can adjust priority with update to thing" do
      new_priority=thing_image.priority==0 ? thing_image.priority - 1 : 9;
      new_name="changed"
      expect(ThingImage.find(thing_image.id).priority).to_not eq(new_priority)
      expect(Thing.find(linked_thing.id).name).to_not eq(new_name)

      within("sd-thing-editor .thing-form") do
        #find and change the priority and thing field
        find_field("thing-name", :with=>linked_thing.name, :readonly=>false)
        expect(page).to have_button("Update Thing", :disabled=>true)
        fill_in("thing-name",:with=>new_name)
        find_field("thing-name",:with=>new_name)
        save_and_open_screenshot unless page.has_button?("Update Thing",:disabled=>false)
        expect(page).to have_button("Update Thing", :disabled=>false)
        image_li=find("div.thing-images span.image_id",:text=>linked_image.id, 
                      :visible=>false).find(:xpath,"../..")
        within(image_li) do
          fill_in("image-priority", :with=>new_priority)
        end
        save_and_open_screenshot unless page.has_button?("Update Thing",:disabled=>false)
        click_button("Update Thing")

        #we need to wait for button to change before going forward
        expect(page).to have_button("Update Thing",:disabled=>true,:wait=>5)
        expect(page).to have_no_button("Update Image Links")

        #verify priority displayed on the page
        expect(page).to have_field("thing-name", :with=>new_name)
        within(".thing-images ul li", :text=>displayed_caption(linked_image)) do
          expect(page).to have_field("image-priority", :with=>new_priority)
        end
        #verify database has the expected values
        expect(ThingImage.find(thing_image.id).priority).to eq(new_priority)
        expect(Thing.find(linked_thing.id).name).to eq(new_name)
      end
    end

    it "update disabled until dirty edit" do
      within("sd-thing-editor .thing-form") do
        expect(page).to have_button("Update Thing",:disabled=>true)
        expect(page).to have_no_button("Update Image Links")
        expect(page).to have_css("div.thing-images span.image_id",:text=>linked_image.id,
                                 :visible=>false,:wait=>5)

        #editing only a link causes only the link update to be enabled
        image_li=find("div.thing-images span.image_id",:text=>linked_image.id, 
                      :visible=>false).find(:xpath,"../..")
        within(image_li) do
          fill_in("image-priority", :with=>thing_image.priority+1)
        end
        expect(page).to have_no_button("Update Thing")
        expect(page).to have_button("Update Image Links", :disabled=>false)

        #editing name causes entire object update to be enabled
        find_field("thing-name", :with=>linked_thing.name)
        fill_in("thing-name", :with=>"new name")
        expect(page).to have_button("Update Thing", :disabled=>false)
        expect(page).to have_no_button("Update Image Links")
      end
    end

  end

  shared_examples "cannot edit link" do
    before(:each) { visit_thing linked_thing }
    it "cannot view priority of image" do
      within("sd-thing-editor") do
        expect(page).to have_css(".thing-form")
        expect(page).to have_no_field("image-priority")
      end
    end
  end

  shared_examples "can remove link" do |role|
    before(:each) { visit_thing linked_thing }

    it "can remove link to image" do
      expect(ThingImage.where(:id=>linked_image.id)).to exist
      within ("sd-thing-editor .thing-form") do
        expect(page).to have_css(".thing-images ul li",:text=>displayed_caption(linked_image))

        #delete the link
        within(".thing-images ul li", :text=>displayed_caption(linked_image)) do
          find_field("image-delete").set(true)
        end
        button = "Update Image Links"
        expect(page).to have_button(button,:disabled=>false)
        click_button(button)
          # wait for page to refresh
        expect(page).to have_no_button(button)

        #link should no longer be displayed
        expect(page).to have_no_css(".thing-images ul li",
                                    :text=>displayed_caption(linked_image))
        #link is removed from database
        expect(ThingImage.where(:id=>linked_image.id)).to_not exist
      end
    end

    it "can remove link with update to thing", :if=>role == Role::ORGANIZER do
      expect(Thing.find(linked_thing.id).name).to eq(linked_thing.name)
      expect(ThingImage.where(:id=>linked_image.id)).to exist

      within("sd-thing-editor .thing-form") do
        expect(page).to have_css(".thing-images ul li", :text=>displayed_caption(linked_image))
        expect(page).to have_field("thing-name", :with=>linked_thing.name,:readonly=>false)

        #delete the link while updating thing
        new_name="changed name"
        fill_in("thing-name", :with=>new_name)
        find_field("thing-name", :with=>new_name)
        within(".thing-images ul li", :text=>displayed_caption(linked_image)) do
          find_field("image-delete").set(true)
        end
        #save_and_open_page
        click_button("Update Thing",:wait=>5)

        # wait for page to refresh
        expect(page).to have_button("Update Thing", :disabled=>true)

        #link should no longer be displayed
        expect(page).to have_no_css(".thing-images ul li",
                                    :text=>displayed_caption(linked_image))
        #name should be updated
        expect(page).to have_no_field("thing-name", :with=>linked_thing.name)
        expect(page).to have_field("thing-name", :with=>new_name,:visible=>false)
        #link is removed from database
        expect(ThingImage.where(:id=>linked_image.id)).to_not exist
        expect(Thing.find(linked_thing.id).name).to eq(new_name)
      end
    end


    it "update disabled until dirty select", :if=> role==Role::ORGANIZER do
      within("sd-thing-editor .thing-form") do
        expect(page).to have_button("Update Thing", :disabled=>true)
        expect(page).to have_no_button("Update Image Links")

        #editing only a link causes only the link update to be enabled
        within(".thing-images ul li", :text=>displayed_caption(linked_image)) do
          find_field("image-delete").set(true)
        end
        expect(page).to have_no_button("Update Thing")
        expect(page).to have_button("Update Image Links", :disabled=>false)

        #editing name causes entire object update to be enabled
        fill_in("thing-name", :with=>"new name")
        expect(page).to have_button("Update Thing", :disabled=>false)
        expect(page).to have_no_button("Update Image Links")
      end
    end
  end

  shared_examples "cannot remove link" do
    before(:each) { visit_thing linked_thing }
    it "cannot select link to delete" do
      within("sd-thing-editor") do
        expect(page).to have_css(".thing-form")
        expect(page).to have_no_field("image-delete")
      end
    end

    it "does not display update (links) button" do
      within("sd-thing-editor") do
        expect(page).to have_css(".thing-form")
        expect(page).to have_no_button("Update Image Links")
        expect(page).to have_no_button("Update Thing")
      end
    end
  end



  context "anonymous" do
    it_behaves_like "can get links"
    it_behaves_like "cannot create link"
    it_behaves_like "cannot edit link"
    it_behaves_like "cannot remove link"
  end
  context "authenticated" do
    before(:each) { login authenticated }
    it_behaves_like "can get links"
    it_behaves_like "cannot create link"
    it_behaves_like "cannot edit link"
    it_behaves_like "cannot remove link"
  end
  context "alt member" do
    before(:each) { login alt_member }
    it_behaves_like "can get links"
    it_behaves_like "cannot create link"
    it_behaves_like "cannot edit link"
    it_behaves_like "cannot remove link"
  end
  context "member" do
    before(:each) { login member }
    it_behaves_like "can get links"
    it_behaves_like "can create links"
    it_behaves_like "cannot edit link"
    it_behaves_like "cannot remove link"
  end
  context "organizer" do
    before(:each) { login organizer }
    it_behaves_like "can get links"
    it_behaves_like "can create links"
    it_behaves_like "can edit link"
    it_behaves_like "can remove link", Role::ORGANIZER
  end
  context "admin" do
    before(:each) { login admin }
    it_behaves_like "can get links"
    it_behaves_like "cannot create link"
    it_behaves_like "cannot edit link"
    it_behaves_like "can remove link", Role::ADMIN
  end
end
