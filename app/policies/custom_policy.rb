class CustomPolicy < ApplicationPolicy
  def you_betcha?
    true
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
