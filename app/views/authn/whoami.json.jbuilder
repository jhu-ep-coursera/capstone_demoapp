if @user
  json.extract! @user, :id, :provider, :uid, :name, :email
  json.user_roles @roles do |role|
    json.role_name role[0]
    json.resource role[1]  if role[1]
  end
end
