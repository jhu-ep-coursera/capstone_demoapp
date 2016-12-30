require 'rails_helper'

RSpec.describe "Authentication Api", type: :request do

  context "sign-up" do
    context "valid registration" do
      it "successfully creates account"
    end

    context "invalid registration" do
      context "missing information" do
        it "reports error with messages"
      end

      context "non-unique information" do
        it "reports non-unique e-mail"
      end
    end
  end

  context "anonymous user" do
    it "accesses unprotected"
    it "fails to access protected resource"
  end

  context "login" do
    context "valid user login" do
      it "generates access token"
      it "grants access to resource"
      it "grants access to resource multiple times"
      it "logout"
    end
    context "invalid password" do
      it "rejects credentials"
    end
  end

end
