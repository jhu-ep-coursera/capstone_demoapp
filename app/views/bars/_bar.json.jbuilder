#json.extract! bar, :id, :name, :created_at, :updated_at

json.id bar.id.to_s
json.name bar.name
json.created_at bar.created_at
json.updated_at bar.updated_at
json.url bar_url(bar, format: :json)
