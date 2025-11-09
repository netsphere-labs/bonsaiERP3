
# Rails 6.1 は 2020年12月.

source 'https://rubygems.org'

ruby '>= 3.1.0'

gem 'rails', '~> 6.1.7'

gem 'bootsnap', '~> 1.7.0', require: false

# bootsnap が listen に依存
gem 'listen', '~> 3.4.1' # Required for Rails 6.0 file watcher

# active_support が logger 1.4 に依存 (logger 1.7.0 では動かない).
# Error: uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger (NameError)
gem 'logger', '~> 1.4.4'
gem 'concurrent-ruby', '~> 1.1.10'  # Pin to avoid Logger issues with newer versions

# Assets
# もし 'sass-rails' を使う場合は, 'sprockets-rails'.
gem 'sprockets-rails'

# Rails6 は 'sass-rails'.
#   依存 sassc-rails -> sprockets-rails
gem 'sass-rails', '~> 6.0.0'  # Updated for Rails 6.0 compatibility

gem 'coffee-rails' , '~> 5.0.0'

gem 'uglifier' , '>= 4.1.0'

# webpacker は, openssl 3.0 で動かない。生の webpack を使う.
# See https://www.nslabs.jp/rails-switch-from-webpacker-to-jsbundling-rails.rhtml
#gem 'webpacker', '~> 5.4.3'  # Required for Rails 6.0
gem "jsbundling-rails"

# Temporarily adding compass-rails for backward compatibility during upgrade
# Removed compass-rails as it's not compatible with sass-rails 6.0
# gem 'compass-rails', '~> 3.1.0'
gem 'pg', '~> 1.2' # Postgresql adapter - compatible with Rails 6.0
gem 'virtus' # Model generation in simple way
#gem 'squeel' # Better SQL queries

gem 'simple_form', '~> 5.1.0'  # Compatible with Rails 6.0

# Template engines
gem 'haml', '~> 5.1.2'  # Compatible with Rails 5.0
#gem 'erubis', '~> 2.7.0'
# gem 'erb', '~> 2.2.0'

# Pagination
gem 'kaminari', '~> 1.2.1'

gem 'bcrypt', '~> 3.1.16', require: 'bcrypt'
gem 'active_model_serializers', '~> 0.10.12' # ActiveRecord Classes to encode in JSON
gem 'resubject' # Cool presenter

gem 'validates_email_format_of'#, '~> 1.5.3'
gem 'validates_lengths_from_database'
# Hstore accessor
gem 'hstore_accessor'
gem 'jsonb_accessor', '~> 1.3.0'  # Compatible with Rails 6.0
gem 'dragonfly', '~> 1.4.0'

gem "rack-cors", '~> 1.1.1', require: "rack/cors"

gem "responders", "~> 3.0.0"  # Compatible with Rails 6.0
#gem 'zeitwerk', '~> 2.6.0'  # Required for Rails 6.0 autoloading

# Active Storage
gem 'image_processing', '~> 1.12.2'  # For Active Storage variants
gem 'mini_magick', '~> 4.11.0'  # For image processing

group :production do
  gem 'newrelic_rpm', '~> 6.15.0'  # Compatible with Rails 6.0
  gem 'bugsnag', '~> 6.24.0' # Report of errors
  gem 'rack-cache', '~> 1.13.0', require: 'rack/cache'
end

group :development do
  gem "better_errors", '~> 2.9.1'
  gem "binding_of_caller", '~> 1.0.0'
  gem "meta_request", '~> 0.7.3'
  gem "rails_best_practices", '~> 1.23.0'
  # quiet_assets functionality is built into Rails 5+
  gem "bullet", '~> 6.1.5'
  gem "awesome_print", '~> 1.9.2'

  gem "capistrano", '~> 3.16.0'
  gem "capistrano-rails", '~> 1.6.1'
  gem "capistrano-bundler", '~> 2.0.1'
  gem "capistrano-rvm", '~> 0.1.2'
  gem 'web-console', '~> 4.1.0'  # Updated for Rails 6.0
  gem 'spring', '~> 2.1.1'
  gem 'spring-commands-rspec', '~> 1.0.4'
end

group :development, :test do
  gem "puma", '~> 4.3.12' # Web server - compatible with Ruby 2.6

  # rspec-rails 8.x for Rails 7.2/8.0
  # rspec-rails 6.x for Rails 6.1, 7.0, 7.1
  gem "rspec-rails", '~> 6.1.5'
  
  gem "ffaker", '~> 2.20.0'
  #gem "pry-byebug", '~> 3.9.0'
end

# Test
group :test do
  gem "capybara", '~> 3.35.3'  # Compatible with Rails 6.0
  gem "database_cleaner", '~> 2.0.1'  # Compatible with Rails 6.0
  gem "factory_bot_rails", '~> 6.2.0' # Compatible with Rails 6.0
  gem "shoulda-matchers", '~> 5.0.0', require: false  # Compatible with Rails 6.0
  gem "valid_attribute", '~> 2.0.0'
  gem "watchr", '~> 0.7'
  gem "launchy", '~> 2.5.0'
  gem 'rails-controller-testing', '~> 1.0.5'  # For assigns and assert_template in Rails 6.0
  gem 'webdrivers', '~> 5.0.0'  # For system tests in Rails 6.0
end
