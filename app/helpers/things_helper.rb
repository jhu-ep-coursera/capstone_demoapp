module ThingsHelper
  def is_admin?
    @current_user && @current_user.is_admin?
  end
  def restrict_notes? user_roles
    user_roles.empty? && !is_admin?
  end
end 
