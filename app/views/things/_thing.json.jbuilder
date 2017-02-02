json.extract! thing, :id, :name, :description, :created_at, :updated_at
json.notes thing.notes   unless restrict_notes? thing.user_roles
json.url thing_url(thing, format: :json)
json.user_roles thing.user_roles    unless thing.user_roles.empty?
