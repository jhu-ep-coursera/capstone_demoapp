json.extract! image, :id, :caption, :creator_id, :created_at, :updated_at
json.url image_url(image, format: :json)
json.user_roles image.user_roles     unless image.user_roles.empty?
