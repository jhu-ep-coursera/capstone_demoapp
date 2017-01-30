class ImagePolicy < ApplicationPolicy
  def index?
    true
  end
  def create?
    @user
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
