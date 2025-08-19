xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.rss version: "2.0", "xmlns:g" => "http://base.google.com/ns/1.0" do
  xml.channel do

    # Store info
    cache current_store do
      xml.title       current_store.name
      xml.link        root_url
      xml.description current_store.meta_description
    end

    # Product feed
    cache [storefront_products_scope, current_currency] do
      storefront_products_scope.find_each do |product|
        product.variants_and_option_values(current_currency).each do |variant|
          
          xml.item do
            # Variant-specific ID
            xml.tag! "g:id", variant.sku.presence || "product-#{product.id}-variant-#{variant.id}"

            # Title (with variant options)
            title = [product.name, variant.options_text.presence].compact.join(" - ")
            xml.tag! "g:title", title.truncate(150)

            # Description
            xml.tag! "g:description", product.storefront_description&.truncate(5000)

            # Product page URL
            xml.tag! "g:link", spree_storefront_resource_url(product)

            # Variant image (fallback to product image)
            image_url =
              if variant.images.any?
                spree_image_url(variant.images.first, width: 500, height: 500)
              elsif product.featured_image.present?
                spree_image_url(product.featured_image, width: 500, height: 500)
              end
            xml.tag! "g:image_link", image_url if image_url

            # Availability
            xml.tag! "g:availability", variant.in_stock? ? "in_stock" : "out_of_stock"

            # Dates
            xml.tag! "g:availability_date", product.available_on.strftime("%Y-%m-%dT%H:%M%z") if product.available_on?
            xml.tag! "g:expiration_date", product.discontinue_on.strftime("%Y-%m-%dT%H:%M%z") if product.discontinue_on?

            # Price
            xml.tag! "g:price", format('%.2f', variant.display_price.to_d) + " #{current_currency}"

            # Option attributes
            variant.option_values.each do |opt|
              case opt.option_type.presentation.downcase
              when "color"
                xml.tag! "g:color", opt.presentation
              when "size"
                xml.tag! "g:size", opt.presentation
              when "material"
                xml.tag! "g:material", opt.presentation
              else
                xml.tag! "g:custom_label_0", "#{opt.option_type.presentation}: #{opt.presentation}"
              end
            end

            # Category & Brand
            xml.tag! "g:product_type", product_breadcrumb_taxons(product).map(&:name).join(' > ')
            xml.tag! "g:brand", product.brand&.name if product.brand.present?

            # Shipping weight (variant first, fallback to product)
            variant_weight = variant.weight.presence || product.weight
            if variant_weight.present?
              weight_units = Spree::Config.try(:weight_units).presence || 'g'
              xml.tag! "g:shipping_weight", "#{variant_weight} #{weight_units}"
            end
          end

        end
      end
    end

  end
end
