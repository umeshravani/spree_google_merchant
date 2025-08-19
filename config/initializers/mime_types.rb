# Ensure Rails knows how to respond_to :gzip
Mime::Type.register "application/x-gzip", :gzip unless Mime::Type.lookup_by_extension(:gzip)
