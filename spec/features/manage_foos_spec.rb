require 'rails_helper'
require 'support/foo_ui_helper.rb'

RSpec.feature "ManageFoos", type: :feature, :js=>true do
  include_context "db_cleanup_each"
  include FooUiHelper
  FOO_FORM_XPATH=FooUiHelper::FOO_FORM_XPATH
  FOO_LIST_XPATH=FooUiHelper::FOO_LIST_XPATH
  let(:foo_state) { FactoryGirl.attributes_for(:foo) }

  feature "view existing Foos" do
    let(:foos) { (1..5).map{ FactoryGirl.create(:foo) }.sort_by {|v| v["name"]} }

    scenario "when no instances exist" do
      visit root_path
      within(:xpath,FOO_LIST_XPATH) do     #<== waits for ul tag
        expect(page).to have_no_css("li")  #<== waits for ul li tag
        expect(page).to have_css("li", count:0) #<== waits for ul li tag
        expect(all("ul li").size).to eq(0) #<== no wait
      end
    end

    scenario "when instances exist" do
      visit root_path  if foos   #need to touch collection before hitting page
      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("li:nth-child(#{foos.count})") #<== waits for li(5)
        expect(page).to have_css("li", count:foos.count)        #<== waits for ul li tag
        expect(all("li").size).to eq(foos.count)                #<== no wait
        foos.each_with_index do |foo, idx|
          expect(page).to have_css("li:nth-child(#{idx+1})", :text=>foo.name)
        end
      end
    end
  end

  feature "add new Foo" do
    background(:each) do
      visit root_path
      expect(page).to have_css("h3", text:"Foos") #on the Foos page
      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("li", count:0)      #nothing listed
      end
    end

    scenario "has input form" do
      expect(page).to have_css("label", :text=>"Name:")
      expect(page).to have_css("input[name='name'][ng-model*='foo.name']")
      expect(page).to have_css("button[ng-click*='create()']", :text=>"Create Foo")
      expect(page).to have_button("Create Foo")
    end

    scenario "complete form" do
      within(:xpath,FOO_FORM_XPATH) do
        fill_in("name", :with=>foo_state[:name])
        click_button("Create Foo")
      end
      within(:xpath,FOO_LIST_XPATH) do
        using_wait_time 5 do
          expect(page).to have_css("li", count:1)
          expect(page).to have_content(foo_state[:name])
        end
      end
    end

    scenario "complete form with XPath" do
      #find(:xpath, "//input[@ng-model='foosVM.foo.name']").set(foo_state[:name])
      #find(:xpath, "//button[@ng-click='foosVM.create()']").click
      find(:xpath, "//input[contains(@ng-model,'foo.name')]").set(foo_state[:name])
      find(:xpath, "//button[contains(@ng-click,'create()')]").click
      within(:xpath,FOO_LIST_XPATH) do
        using_wait_time 5 do
          expect(page).to have_xpath(".//li", count:1)
          #expect(page).to have_xpath("//*[text()='#{foo_state[:name]}']")
          expect(page).to have_content(foo_state[:name])
        end
      end
    end

    scenario "complete form with helper" do
      create_foo foo_state

      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("li", count:1)
      end
    end
  end

  feature "with existing Foo" do
    background(:each) do
      create_foo foo_state
    end

    scenario "can be updated" do
      existing_name=foo_state[:name]
      new_name=FactoryGirl.attributes_for(:foo)[:name]

      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("li", :count=>1)
        expect(page).to have_css("li", :text=>existing_name)
        expect(page).to have_no_css("li", :text=>new_name)
      end

      update_foo(existing_name, new_name)

      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("li", :count=>1)
        expect(page).to have_no_css("li", :text=>existing_name)
        expect(page).to have_css("li", :text=>new_name)
      end
    end

    scenario "can be deleted" do
      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_css("a",text:foo_state[:name])
      end

      delete_foo foo_state[:name]

      within(:xpath,FOO_LIST_XPATH) do
        expect(page).to have_no_css("a",text:foo_state[:name])
      end
    end

  end
end
