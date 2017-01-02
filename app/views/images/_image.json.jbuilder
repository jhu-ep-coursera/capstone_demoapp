json.extract! image, :id, :caption, :creator_id, :created_at, :updated_at
json.url image_url(image, format: :json)