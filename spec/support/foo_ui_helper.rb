module FooUiHelper
  FOO_FORM_XPATH="//h3[text()='Foos']/../form"
  FOO_LIST_XPATH="//h3[text()='Foos']/../ul"

  def create_foo foo_state
    visit "#{root_path}/#/foos" unless page.has_css?("h3", text:"Foos")
    expect(page).to have_css("h3", text:"Foos") #on the Foos page
    within(:xpath,FOO_FORM_XPATH) do
      fill_in("name", :with=>foo_state[:name])
      expect(page).to have_field("name", :with=>foo_state[:name])
      click_button("Create Foo", :disabled=>false)
    end
    within(:xpath,FOO_LIST_XPATH) do
      using_wait_time 5 do
        expect(page).to have_css("li a",:text=>foo_state[:name])
      end
    end
  end

  def update_foo existing_name, new_name
    visit "#{root_path}/#/foos" unless page.has_css?("h3", text:"Foos")
    expect(page).to have_css("h3", text:"Foos") #on the Foos page
    within(:xpath,FOO_LIST_XPATH) do
      find("a",:text=>existing_name).click
    end
    within(:xpath,FOO_FORM_XPATH) do
      find_field("name", :readonly=>false, :wait=>5)
      fill_in("name", :with=>new_name)
      click_button("Update Foo")
    end
    within(:xpath,FOO_LIST_XPATH) do
      expect(page).to have_css("li a",:text=>new_name)
    end
  end

  def delete_foo name
    visit "#{root_path}/#/foos" unless page.has_css?("h3", text:"Foos")
    within(:xpath,FOO_LIST_XPATH) do
      find("li a",:text=>name).click
    end
    find(:xpath, "//button[@ng-click='foosVM.remove()']").click
    within(:xpath,FOO_LIST_XPATH) do
      expect(page).to have_no_css("li a",:text=>name)
    end
  end
end
