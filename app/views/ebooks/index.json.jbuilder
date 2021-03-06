json.array!(@ebooks) do |ebook|
  json.extract! ebook, :id, :title, :description, :wwwlink, :summary
  json.url ebook_url(ebook, format: :json)
end
