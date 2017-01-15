require 'rails_helper'

RSpec.feature "Authns", type: :feature, :js=>true do
  include_context "db_cleanup_each"
  let(:user_props) { FactoryGirl.attributes_for(:user) }

  feature "sign-up" do
    context "valid registration" do
      scenario "creates account and navigates away from signup page" do
        start_time=Time.now
        signup user_props

        #check we re-directed to home page
        expect(page).to have_no_css("#signup-form")
        #check the DB for the existance of the User account
        user=User.where(:email=>user_props[:email]).first
        #make sure we were the ones that created it
        expect(user.created_at).to be > start_time        
      end
    end

    context "rejected registration" do
      before(:each) do
        signup user_props 
        expect(page).to have_no_css("#signup-form")
      end

      scenario "account not created and stays on page" do
        dup_user=FactoryGirl.attributes_for(:user, :email=>user_props[:email])
        signup dup_user, false #should get rejected by server

        #account not created
        expect(User.where(:email=>user_props[:email],:name=>user_props[:name])).to exist
        expect(User.where(:email=>dup_user[:email],:name=>dup_user[:name])).to_not exist

        expect(page).to have_css("#signup-form")
        expect(page).to have_button("Sign Up")
      end

      scenario "displays error messages" do
        bad_props=FactoryGirl.attributes_for(:user, 
                                   :email=>user_props[:email],
                                   :password=>"123")
                            .merge(:password_confirmation=>"abc")
        signup bad_props, false

        #displays error information
        expect(page).to have_css("#signup-form > span.invalid",
                                 :text=>"Password confirmation doesn't match Password")
        expect(page).to have_css("#signup-form > span.invalid",
                                 :text=>"Password is too short")
        expect(page).to have_css("#signup-form > span.invalid",
                                 :text=>"Email already in use")
        expect(page).to have_css("#signup-email span.invalid",:text=>"already in use")
        expect(page).to have_css("#signup-password span.invalid",:text=>"too short")
        within("#signup-password_confirmation") do
          expect(page).to have_css("span.invalid",:text=>"doesn't match")
        end
      end

      scenario "clears error messages on page update" do
        bad_props=FactoryGirl.attributes_for(:user, 
                                   :email=>user_props[:email],
                                   :password=>"123")
                            .merge(:password_confirmation=>"abc")
        signup bad_props, false
        expect(page).to have_css("#signup-email span.invalid")
        expect(page).to have_css("#signup-password > span.invalid")
        expect(page).to have_css("#signup-password_confirmation > span.invalid")

        fill_in("signup-email", :with=>"anylegal@email.com")

        expect(page).to have_no_css("#signup-email span.invalid")
        expect(page).to have_no_css("#signup-password > span.invalid")
        expect(page).to have_no_css("#signup-password-confirm > span.invalid")
      end
    end

    context "invalid field" do
      after(:each) do
        within("#signup-form") do
          expect(page).to have_button("Sign Up", :disabled=>true)
        end
      end

      scenario "bad email" do
        fillin_signup FactoryGirl.attributes_for(:user, :email=>"yadayadayada")
        expect(page).to have_css("input[name='signup-email'].ng-invalid-email")          
      end
      scenario "missing password" do
        fillin_signup FactoryGirl.attributes_for(:user, :password=>nil)
        expect(page).to have_css("input[name='signup-password'].ng-invalid-required")
        expect(page).to have_css("input[name='signup-password_confirmation'].ng-invalid-required")          
      end
    end
  end

  feature "anonymous user" do
    scenario "shown login form" do
      visit root_path
      click_on("Login")
      expect(page).to have_no_css("#logout-form")
      expect(page).to have_css("#login-form")
    end
  end

  feature "login" do
    background(:each) do
      signup user_props
      login user_props
    end

    context "valid user login" do
      scenario "closes form and displays current user name" do
        expect(page).to have_css("#navbar-loginlabel",:text=>/#{user_props[:name]}/)
        expect(page).to have_no_css("#login-form")
        expect(page).to have_no_css("#logout-form") #dropdown goes away
      end

      scenario "menu shows logout option with identity" do
        find("#navbar-loginlabel").click
        expect(page).to have_css("#user_id",:text=>/.+/, :visible=>false)
        expect(page).to have_css("#logout-identity label",:text=>user_props[:name])
        within ("#logout-form") do
          expect(page).to have_button("Logout")
        end
      end

      scenario "can access authenticated resources"
    end

    context "invalid login" do
      scenario "error message displayed and leaves user unauthenticated"
    end
  end

  feature "logout" do
    background(:each) do
      signup user_props
      login user_props
    end

    scenario "closes form and removes user name" do
      login_criteria=["#navbar-loginlabel", :text=>"Login"]
      user_name_criteria=["#navbar-loginlabel", :text=>/#{user_props[:name]}/]
      user_id_criteria=["#user_id",:visible=>false]

      expect(page).to have_no_css(*login_criteria)
      expect(page).to have_css(*user_name_criteria)
      expect(page).to have_css(*user_id_criteria)

      logout

      expect(page).to have_no_css(*user_id_criteria)
      expect(page).to have_no_css(*user_name_criteria)
      expect(page).to have_css(*login_criteria)
    end

    scenario "can no longer access authenticated resources"
  end
end
