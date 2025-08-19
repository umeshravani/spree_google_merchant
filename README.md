# SpreeGoogleMerchantFeed

This is a Google Merchant extension for [Spree Commerce](https://spreecommerce.org), an open source e-commerce platform built with Ruby on Rails. Adds the ability to provide products listings to Google Merchant Center for Spree Commerce.


## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem 'spree_google_merchant_feed', git: 'https://github.com/umeshravani/spree_google_merchant'
    ```

2. Install the migrations:

    ```sh
    bundle exec rails g spree_google_merchant_feed:install
    ```

3. Run the migrations:

    ```sh
    bundle exec rails db:migrate
    ```

4. Restart your server

  If your server was running, restart it so that it can find the assets properly.


## Releasing a new version

```shell
bundle exec gem bump -p -t
bundle exec gem release
```

For more options please see [gem-release README](https://github.com/svenfuchs/gem-release)

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

Copyright (c) 2025 OlympusOne, released under the MIT

## Google Merchant Center Integration

To use your Google Merchant endpoint as a data source in Google Merchant Center:

1. **Deploy your endpoint**  
  Ensure your authentication and data endpoints are publicly accessible and return the required data format (e.g., XML, CSV, or JSON).  
  For this extension, your endpoint will typically be:  
  `https://yoursite.com/google_merchant/products.xml`

2. **Copy your endpoint URL**  
  This is the URL that Google Merchant Center will fetch data from.

3. **Add as a data feed in Google Merchant Center**
   - Go to [Google Merchant Center](https://merchants.google.com/).
   - In the header, click **Settings & tools**.
   - Select **Data sources**.
   - Click **Add product source**.
   - Choose **Add products from a file**.
   - Enter your endpoint URL (e.g., `https://yoursite.com/google_merchant/products.xml`) as the feed source.
   - Set fetch frequency and credentials if authentication is required.

4. **Test and verify**  
  After saving, Google will attempt to fetch your data. Check for errors and ensure your feed is processed correctly.
