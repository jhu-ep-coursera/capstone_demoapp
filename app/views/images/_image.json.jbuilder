json.extract! image, :id, :caption, :creator_id, :created_at, :updated_at
json.url image_url(image, format: :json)
json.content_url image_content_url(image)
json.user_roles image.user_roles     unless image.user_roles.empty?
