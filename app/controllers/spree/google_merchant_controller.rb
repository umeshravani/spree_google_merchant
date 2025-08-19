module Spree
  class GoogleMerchantController < StoreController
    include BaseHelper
    include StorefrontHelper

    def products
      # Build once; reuse for both formats
      xml = render_to_string(template: 'spree/google_merchant/products', formats: [:xml])

      respond_to do |format|
        format.xml  { render xml: xml }
        format.gzip do
          gz_xml = ActiveSupport::Gzip.compress(xml)
          send_data gz_xml,
                    filename: 'products.xml.gz',
                    type: 'application/x-gzip',
                    disposition: 'inline'
        end
      end
    end
  end
end
