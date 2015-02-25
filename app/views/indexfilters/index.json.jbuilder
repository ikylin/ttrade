json.array!(@indexfilters) do |indexfilter|
  json.extract! indexfilter, :id, :name, :script, :platform, :samplecount, :wincount, :losscount, :marketdatecount
  json.url indexfilter_url(indexfilter, format: :json)
end
