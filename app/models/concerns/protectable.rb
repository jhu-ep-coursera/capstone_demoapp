module Protectable
  extend ActiveSupport::Concern

  included do
    def user_roles
      @user_roles ||= []
    end
  end
end
