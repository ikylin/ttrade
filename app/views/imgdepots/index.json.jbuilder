json.array!(@imgdepots) do |imgdepot|
  json.extract! imgdepot, :id, :titile, :summary
  json.url imgdepot_url(imgdepot, format: :json)
end
