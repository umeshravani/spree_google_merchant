Spree::Core::Engine.add_routes do
  # XML (default)
  get '/google_merchant/products', to: 'google_merchant#products', defaults: { format: :xml }

  # GZIP
  get '/google_merchant/products.xml.gz',
      to: 'google_merchant#products',
      defaults: { format: :gzip }
end
