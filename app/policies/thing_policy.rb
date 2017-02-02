class ThingPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    originator?
  end

  def update?
    organizer?
  end

  def destroy?
    organizer_or_admin?
  end
  class Scope < Scope
    def user_roles members_only=true
      member_join = members_only ? "join" : "left join"
      joins_clause=["#{member_join} Roles r on r.mname='Thing'",
                    "r.mid=Things.id",
                    "r.user_id #{user_criteria}"].join(" and ")
      scope.select("Things.*, r.role_name")
           .joins(joins_clause)
           .tap {|s|
             if members_only
               s.where("r.role_name"=>[Role::ORGANIZER, Role::MEMBER])
             end}
    end
    def resolve
      user_roles 
    end
  end
end
