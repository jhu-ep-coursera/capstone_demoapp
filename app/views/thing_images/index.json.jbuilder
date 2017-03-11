json.array!(@thing_images) do |ti|
  json.extract! ti, :id, :thing_id, :image_id, :priority, :creator_id, :created_at, :updated_at
  json.thing_name ti.thing_name        if ti.respond_to?(:thing_name)
  json.image_caption ti.image_caption  if ti.respond_to?(:image_caption)
  json.image_content_url image_content_url(ti.image_id)    if ti.image_id

  if ti.respond_to?(:lng) && ti.lng
    json.position do
      json.lng ti.lng
      json.lat ti.lat
    end
  end
  if ti.respond_to?(:distance) && ti.distance && ti.distance >= 0
    json.distance ti.distance.to_f
  end
end
