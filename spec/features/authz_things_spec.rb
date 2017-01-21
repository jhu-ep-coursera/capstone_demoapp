require 'rails_helper'

RSpec.feature "AuthzThings", type: :feature, js:true do
  include_context "db_cleanup_each"

  let(:originator)    { create_user }
  let(:organizer)     { originator }
  let(:member)        { create_user }
  let(:authenticated) { create_user }
  let(:thing_props)   { FactoryGirl.attributes_for(:thing) }
  let(:things)        { FactoryGirl.create_list(:thing, 3) }
  let(:thing)         { things[0] }

  def visit_thing thing
    things
    visit "#{ui_path}/#/things/#{thing.id}"
    expect(page).to have_css("sd-thing-editor")
    within("sd-thing-editor") do
      expect(page).to have_css(".thing-form span.thing_id", 
                               text:thing.id, visible:false)
    end
  end

  def visit_things
    things
    visit "#{ui_path}/#/things/"
    within("sd-thing-selector", :wait=>5) do
      if logged_in? 
        expect(page).to have_css(".thing-list")
        expect(page).to have_css(".thing-list li",:count=>things.count)
        expect(page).to have_css(".thing-form span.thing_id", 
                                 text:thing.id, visible:false)
      end
    end
  end


  shared_examples "cannot list things" do
    it "does not list things" do
      visit_things
      expect(page).to have_css(".thing-list",:visible=>false)
    end
  end
  shared_examples "can list things" do
    it "lists things" do
      visit_things
      within("sd-thing-selector .thing-list") do
        things.each do |t|
          expect(page).to have_css("li a",:text=>t.name)
          expect(page).to have_css(".thing_id",:text=>t.id,:visible=>false)
          expect(page).to have_no_css(".thing_id") #should be hidden
        end
      end
    end
  end

  shared_examples "displays correct buttons for role" do |displayed,not_displayed|
    it "displays correct buttons" do
      within("sd-thing-editor .thing-form") do
        displayed.each do |button|
          #create is present and disabled until name filled in
          disabled_value = ["Create Thing","Update Thing"].include? button
          expect(page).to have_button(button, disabled:disabled_value,:wait=>5)
        end
        not_displayed.each do |button|
          expect(page).to_not have_button(button)
        end
      end
    end
  end

  shared_examples "originator has invalid thing" do
    it "cannot edit description for invalid thing" do
      within("sd-thing-editor .thing-form") do
        expect(page).to have_field("thing-name", :visible=>true)
        expect(page).to have_field("thing-desc", :visible=>false)
        expect(page).to have_field("thing-notes", :visible=>false)
      end
    end
    it "cannot create invalid thing" do
      within("sd-thing-editor .thing-form") do
        expect(page).to have_field("thing-name", :with=>"")
        expect(page).to have_button("Create Thing", :disabled=>true)
      end
    end
  end

  shared_examples "can create valid thing" do
    it "creates thing" do
      within ("sd-thing-editor .thing-form") do
        fill_in("thing-name", :with=>thing_props[:name])
        fill_in("thing-desc", :with=>thing_props[:description])
        fill_in("thing-notes", :with=>thing_props[:notes])
        click_button("Create Thing")
        expect(page).to have_no_button("Create Thing")
      end

      #new thing shows up in list
      visit_things
      expect(page).to have_css(".thing-list ul li a",:text=>thing_props[:name])
    end
  end

  shared_examples "displays thing" do
    it "can display specific thing" do
      visit_thing thing
      within("sd-thing-editor .thing-form") do
        expect(page).to have_css(".thing_id", :text=>thing.id, :visible=>false)
        expect(page).to have_field("thing-name", :with=>thing.name)
        expect(page).to have_no_css(".thing_id") #should be hidden
      end
    end
  end

  shared_examples "can clear thing" do
    it "clears thing" do
      within("sd-thing-editor .thing-form") do
        expect(page).to have_css(".thing_id", :text=>thing.id, :visible=>false)
        expect(page).to have_field("thing-name", :with=>thing.name)
        click_button("Clear Thing")
        expect(page).to have_no_css(".thing_id", :text=>thing.id, :visible=>false)
        expect(page).to have_field("thing-name", :with=>"")
        expect(page).to have_field("thing-desc", :visible=>false, :with=>"")
        expect(page).to have_field("thing-notes", :visible=>false, :with=>"")
      end
    end
  end

  shared_examples "cannot see details" do
    it "hides details" do
      within("sd-thing-editor .thing-form") do 
        expect(page).to have_field("thing-name", :with=>thing.name)
        expect(page).to have_field("thing-desc", :with=>thing.description)
        expect(page).to have_field("thing-notes",:visible=>false)
      end
    end
  end
  shared_examples "can see details" do |readonly|
    it "shows details" do
      within("sd-thing-editor .thing-form") do 
        expect(page).to have_field("thing-name", :with=>thing.name)
        expect(page).to have_field("thing-desc", :with=>thing.description)
        expect(page).to have_field("thing-notes", :visible=>true, :readonly=>readonly)
      end
    end
  end

  shared_examples "can update thing" do
    it "updates thing" do
      within("sd-thing-editor .thing-form") do
        fill_in("thing-name", :with=>thing_props[:name])
        fill_in("thing-desc", :with=>thing_props[:description])
        fill_in("thing-notes",:with=>thing_props[:notes])
        click_button("Update Thing")
        expect(page).to have_no_button("Update Thing")
        click_button("Clear Thing")
        expect(page).to have_no_button("Clear Thing")
      end

      #updated thing shows up in list
      within("sd-thing-selector .thing-list") do
        expect(page).to have_css("li a",:text=>thing_props[:name],:wait=>5)
      end
    end
  end

  def update_text_field field_name
    within("sd-thing-editor .thing-form") do
      expect(page).to have_no_button("Update Thing")
      new_text=Faker::Lorem.characters(5000)
      fill_in(field_name, :with=>new_text)
      text_field=find("textarea[name='#{field_name}']")
      expect(text_field.value.size).to eq(4000)  #stops as maxlength
      expect(text_field.value).to eq(new_text.slice(0,4000))
    end
  end

  shared_examples "cannot update to invalid thing" do
    it "cannot update with invalid name" do
      within("sd-thing-editor .thing-form") do
          #initialize disabled becuase not $dirty
        expect(page).to have_no_button("Update Thing")
        fill_in("thing-name", :with=>"abc")
        expect(page).to have_button("Update Thing", :disabled=>false)
        fill_in("thing-name", :with=>"")
        expect(page).to have_button("Update Thing", :disabled=>true)
      end
    end
    it "cannot update with invalid description" do
      update_text_field "thing-desc"
    end
    it "cannot update with invalid notes" do
      update_text_field "thing-notes"
    end
  end

  shared_examples "can delete thing" do
    it "deletes thing" do
      visit_things
      within("sd-thing-selector .thing-list") do
        expect(page).to have_css(".thing_id", :text=>thing.id, :visible=>false)
        expect(page).to have_css("li a",:text=>thing.name)
      end

      visit_thing thing
      within("sd-thing-editor .thing-form") do
        click_button("Delete Thing")
        expect(page).to have_no_button("Delete Thing",:wait=>5)
      end

      within("sd-thing-selector .thing-list") do
        expect(page).to have_no_css(".thing_id", :text=>thing.id, :visible=>false)
        expect(page).to have_no_css("li a",:text=>thing.name)
      end
    end
  end

  context "no thing selected" do
    after(:each) { logout }

    context "unauthenticated user" do
      before(:each) { visit_things }
      it_behaves_like "cannot list things"
      it_behaves_like "displays correct buttons for role", 
          [], 
          ["Create Thing", "Clear Thing", "Update Thing", "Delete Thing"]
    end
    context "authenticated user" do
      before(:each) { login authenticated; visit_things }

      it_behaves_like "can list things"
      it_behaves_like "displays correct buttons for role", 
          ["Create Thing"], ["Clear Thing", "Update Thing", "Delete Thing"],
          []
      it_behaves_like "originator has invalid thing"
      it_behaves_like "can create valid thing"
    end
  end

  context "things posted" do
    before(:each) do
      things #touch things to have them created before visiting page
      visit "#{ui_path}/#/things/"
      logout
      expect(page).to have_css("sd-thing-selector")
    end
    after(:each) { logout }

    def select_thing
      within("sd-thing-selector .thing-list") do
        find("span.thing_id",:text=>thing.id, :visible=>false).find(:xpath,"..").click
      end
      within("sd-thing-editor .thing-form") do
        expect(page).to have_css("span.thing_id",:text=>thing.id, :visible=>false)
      end
    end

    context "user selects thing" do
      it_behaves_like "displays thing"

      context "anonymous user" do
        before(:each) { visit "#{ui_path}/#/things/#{thing.id}" }
        it_behaves_like "displays correct buttons for role", 
            [],
            ["Clear Thing"], ["Create Thing", "Update Thing", "Delete Thing"]
        it_behaves_like "cannot see details"
      end

      context "authenticated user" do
        before(:each) { login authenticated; select_thing }
        it_behaves_like "displays correct buttons for role", 
            ["Clear Thing", "Delete Thing"],
            ["Create Thing", "Update Thing"]
        it_behaves_like "displays thing"
        it_behaves_like "can see details", false
        it_behaves_like "can update thing"
        it_behaves_like "cannot update to invalid thing"
        it_behaves_like "can clear thing"
        it_behaves_like "can delete thing"
      end
    end

    context "user logs out" do
      it "displays last selected thing as non-member" do
        login organizer
        select_thing
        within("sd-thing-editor .thing-form") do
          expect(page).to have_field("thing-name", :with=>thing.name)
          expect(page).to have_field("thing-desc", :visible=>true, 
                                                   :readonly=>false)
          expect(page).to have_field("thing-notes",:visible=>true, 
                                                   :readonly=>false)
          expect(page).to have_css("button");
        end

        logout
        within("sd-thing-editor .thing-form") do
          expect(page).to have_field("thing-name", :with=>thing.name, 
                                                   :readonly=>true)
          expect(page).to have_field("thing-desc", :with=>thing.description, 
                                                   :readonly=>true)
          expect(page).to have_no_field("thing-notes")
          expect(page).to have_no_css("button");
        end
      end
    end

  end
end
