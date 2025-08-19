xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.rss version: "2.0", "xmlns:g" => "http://base.google.com/ns/1.0" do
  xml.channel do

    cache [I18n.locale, current_store.id, current_currency, 'merchant-feed:header'] do
      xml.title       current_store.name
      xml.link        root_url
      xml.description current_store.meta_description
    end

    cache [I18n.locale, current_store.id, current_currency, 'merchant-feed:body'] do
      storefront_products_scope.find_each do |product|
        product.variants_and_option_values(current_currency).each do |variant|
          xml.item do
            # Unique ID
            xml.tag! "g:id", variant.sku.presence || "product-#{product.id}-variant-#{variant.id}"

            # Title
            vtitle = [product.name, variant.options_text.presence].compact.join(" - ")
            xml.tag! "g:title", vtitle.truncate(150)

            # Description
            xml.tag! "g:description", product.storefront_description&.truncate(5000)

            # Product URL
            xml.tag! "g:link", spree_storefront_resource_url(product)

            # Image
            image_url =
              if variant.images.any?
                spree_image_url(variant.images.first, width: 500, height: 500)
              elsif product.respond_to?(:featured_image) && product.featured_image.present?
                spree_image_url(product.featured_image, width: 500, height: 500)
              end
            xml.tag! "g:image_link", image_url if image_url

            # Availability
            xml.tag! "g:availability", variant.in_stock? ? "in_stock" : "out_of_stock"

            # Dates
            xml.tag! "g:availability_date", product.available_on.strftime("%Y-%m-%dT%H:%M%z") if product.available_on?
            if product.respond_to?(:discontinue_on) && product.discontinue_on?
              xml.tag! "g:expiration_date", product.discontinue_on.strftime("%Y-%m-%dT%H:%M%z")
            end

            # Price
            amount = variant.price_in(current_currency)&.amount
            if amount.present?
              xml.tag! "g:price", format('%.2f', amount) + " #{current_currency}"
            end

            # Option attributes
            variant.option_values.each do |opt|
              key = opt.option_type.presentation.to_s.downcase
              val = opt.presentation.to_s

              case key
              when "color"     then xml.tag! "g:color",    val
              when "size"      then xml.tag! "g:size",     val
              when "material"  then xml.tag! "g:material", val
              when "pattern"   then xml.tag! "g:pattern",  val
              when "gender"    then xml.tag! "g:gender",   val
              when "age group","age_group"
                xml.tag! "g:age_group", val
              when "finish"
                xml.tag! "g:material", val # finish → material
              end
            end

            # Category trail
            product_type = product_breadcrumb_taxons(product).map(&:name).join(' > ')
            xml.tag! "g:product_type", product_type if product_type.present?

            # Brand
            brand_name =
              if product.respond_to?(:brand) && product.brand.present?
                product.brand.name
              elsif product.respond_to?(:property)
                product.property('brand')
              end
            xml.tag! "g:brand", brand_name if brand_name.present?

            # Shipping weight
            if product.weight.present?
              weight_units =
                if Spree::Config.preferences.key?(:weight_units) && Spree::Config[:weight_units].present?
                  Spree::Config[:weight_units]
                else
                  'kg'
                end
              xml.tag! "g:shipping_weight", "#{product.weight} #{weight_units}"
            end

            # GTIN
            gtin = product.respond_to?(:property) ? product.property('gtin') : nil
            gtin ||= product.respond_to?(:property) ? product.property('barcode') : nil
            gtin ||= variant.respond_to?(:barcode) ? variant.barcode : nil
            xml.tag! "g:gtin", gtin if gtin.present?

            # MPN
            mpn = product.respond_to?(:property) ? product.property('mpn') : nil
            mpn ||= variant.sku
            xml.tag! "g:mpn", mpn if mpn.present?

            # Condition
            condition =
              if product.respond_to?(:property) && product.property('condition').present?
                product.property('condition').downcase
              else
                'new'
              end
            xml.tag! "g:condition", condition

            # Shipping
            shipping_methods = if defined?(Spree::ShippingMethod)
                                 Spree::ShippingMethod.available
                               else
                                 []
                               end

            if shipping_methods.any?
              shipping_methods.each do |method|
                xml.tag! "g:shipping" do
                  xml.tag! "g:country", current_store.default_country.iso rescue "US"
                  xml.tag! "g:service", method.name
                  if method.calculator.respond_to?(:preferred_amount) && method.calculator.preferred_amount.present?
                    price = method.calculator.preferred_amount
                    xml.tag! "g:price", format('%.2f', price) + " #{current_currency}"
                  else
                    xml.tag! "g:price", "0.00 #{current_currency}"
                  end
                end
              end
            else
              xml.tag! "g:shipping" do
                xml.tag! "g:country", current_store.default_country.iso rescue "US"
                xml.tag! "g:service", "Standard"
                xml.tag! "g:price", "0.00 #{current_currency}"
              end
            end

            # Tax
            if defined?(Spree::TaxRate) && Spree::TaxRate.any?
              Spree::TaxRate.each do |rate|
                xml.tag! "g:tax" do
                  xml.tag! "g:country", rate.zone.try(:countries)&.first&.iso rescue "US"
                  xml.tag! "g:rate", (rate.amount * 100).round(2)
                  xml.tag! "g:tax_ship", "y"
                end
              end
            end

          end
        end
      end
    end

  end
end
