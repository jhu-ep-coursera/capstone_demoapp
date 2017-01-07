module UiHelper
  def signup registration, success=true
    visit "#{ui_path}/#/signup" unless page.has_css?("#signup-form")
    expect(page).to have_css("#signup-form")

    fill_in("signup-email", :with=>registration[:email])
    fill_in("signup-name", :with=>registration[:name])
    fill_in("signup-password", :with=>registration[:password])
    password_confirm = registration[:password_confirmation] ||= registration[:password]
    fill_in("signup-password_confirmation", :with=>password_confirm)
    click_on("Sign Up")  
    if success
      expect(page).to have_no_button("Sign Up")
    else
      expect(page).to have_button("Sign Up")
    end
  end
end
