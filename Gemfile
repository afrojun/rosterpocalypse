source 'https://rubygems.org'

ruby '2.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'pry-rails'

# Rubocop for Ruby style checking
gem 'rubocop', require: false

# Add helpful information on page performance to the bottom of pages
# https://github.com/josevalim/rails-footnotes
gem 'rails-footnotes', '~> 4.0'

# Kaminari for pagination
gem 'kaminari'

# Mixpanel to track user engagement
gem 'mixpanel-ruby'

# Get Browser and OS info
gem 'browser'

# Use Haml for cleaner view templates
gem 'haml'
gem 'html2haml'

# Use oj for fast JSON handling
gem 'oj'
gem 'oj_mimic_json'

# React on Rails
gem 'react_on_rails', '~>6'

# Background ActiveJob task handler
gem 'sidekiq'
# Keep track of failures and allow us to view them in the dashboard
gem 'sidekiq-failures'

# Mailgun for sending emails
gem 'mailgun-ruby', '~>1.1.6'

# Stripe for payment processing
gem 'stripe'
# Gem to help with Stripe webhooks
gem 'stripe_event'

# Twitter Bootstrap 4
gem 'bootstrap', '~> 4.0.0.alpha5'
# Bootstrap Tooltips and popovers depend on tether for positioning
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end
# Better DateTime Picker
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.43'
gem 'momentjs-rails', '>= 2.9.0'

# font-awesome for web fonts CSS
gem 'font-awesome-rails'

# Gem to help with statistical calculations
# https://github.com/thirtysixthspan/descriptive_statistics
gem 'descriptive_statistics', '~> 2.4.0', require: 'descriptive_statistics/safe'

# Robust alternative to Rake for building CLI tools
gem 'thor-rails'

# Used to create images dynamically from webpages
gem 'imgkit'
gem 'wkhtmltoimage-binary'

# https://github.com/icalendar/icalendar
# Gem to create and read iCalendar files
gem 'icalendar'

# Devise for authentication
gem 'devise'
# OAuth gems
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.3.1'
# OAuth clients
gem 'omniauth-bnet'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-reddit', git: 'https://github.com/jackdempsey/omniauth-reddit'
gem 'omniauth-twitter'
# gem 'google-api-client', require: 'google/api_client'

gem 'twitter'

# https://github.com/jumph4x/canonical-rails
# Set rel=canonical in the header for SEO
gem 'canonical-rails', git: 'https://github.com/jumph4x/canonical-rails'

# https://github.com/tylerhunt/rack-canonical-host
# To redirect to always use the 'www' subdomain
gem 'rack-canonical-host'

# Access Granted for Authorization
gem 'access-granted', '~> 1.1.0'
# Better distance of time in words for Rails
gem 'dotiw'
# friendly_id for non-numeric IDs in URLs
gem 'friendly_id', '~> 5.2.0'
# library for creating slugs.
gem 'babosa'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.5'
end

group :test do
  gem 'cucumber-rails', require: false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  # Code coverage stats
  gem 'simplecov', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'guard'
  gem 'guard-rspec'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'mini_racer', platforms: :ruby
