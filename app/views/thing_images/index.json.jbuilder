json.array!(@thing_images) do |ti|
  json.extract! ti, :id, :thing_id, :image_id, :priority, :creator_id, :created_at, :updated_at
  json.thing_name ti.thing_name        if ti.respond_to?(:thing_name)
  json.image_caption ti.image_caption  if ti.respond_to?(:image_caption)
end
