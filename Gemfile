
# Webpacker が Rails 5.1 から導入.
#   Webpacker         Rails
#     1.0   2017 Feb  5.1.0.beta1
#     1.2   2017 Apr  5.1.0
#     3.5.0 2018 Apr  5.2.0
#     4.0.x 2019 Aug  6.0.0

# webpack - openssl 非互換のため, ヴァージョンを前に進めるしかなくなる
#  -> <s>Rails 5.x で, かつ</s> Webpacker を *使わない* 組み合わせにする
# Ruby 3.x + Rails 5.x は動かない. keyword引数の厳密化で, `delegate()` がエラー
# になってしまう

source 'https://rubygems.org'

#ruby '2.1.0'
gem 'rails', '~> 6.1.7'

# Assets
# sass-rails 4.0.5 depends railties < 5.0, >= 4.0.0
gem 'sass-rails' , '~> 6.0'
gem 'coffee-rails' , '~> 5.0'
gem 'uglifier' #    , '>= 2.3.0'
#gem 'jquery-rails'

# gem 'turbo-sprockets-rails3'# Speed assets:precompile

# ruby 3.x で動かない
#gem 'compass-rails', '~> 1.1.3'#, '~> 2.0.alpha.0' # Extend css clases

gem 'pg'   # Postgresql adapter

gem 'virtus' # Model generation in simple way

# ActiveRecord のヴァージョンに繊細
# undefined method `alias_method_chain' for class #<Class:ActiveRecord::Associations::JoinDependency>
# 類似に "baby_squeel" gem があるが、書き方が異なる.
#gem 'squeel' # Better SQL queries

gem 'simple_form'
gem 'haml', '>= 4.0.5'
gem 'kaminari' # Pagination
gem 'bcrypt-ruby', require: 'bcrypt'

# ActiveRecord Classes to encode in JSON
gem 'active_model_serializers', '~> 0.9.13' 

gem 'resubject' # Cool presenter

gem 'validates_email_format_of', '~> 1.5.3'
gem 'validates_lengths_from_database'

group :production do
  gem 'newrelic_rpm'
  gem 'bugsnag' # Report of errors
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rails_best_practices'

  # obsolete: quiet_assets depends railties < 5.0, >= 3.1
  #gem 'quiet_assets'
  
  gem 'roadie' # Styles for email
  # gem 'guard-livereload', require: false
end

group :development, :test do
  gem 'puma'# Web server
  gem 'rspec-rails'
  gem 'ffaker'
  #gem 'pry-remote' # Work binding.pry_remote with Foreman, just call pry-remote in the terminal
  gem 'pry'#, '0.9.11.3'# 0.9.11.4 gives error
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'foreman'
end

# Test
  gem 'capybara'
group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.3.0'
  gem 'spork', '1.0.0rc4' # Newer version gives error with squeel
  gem 'shoulda-matchers' #, '1.4.2'
  gem 'valid_attribute'
  gem 'watchr'
  gem 'launchy'
end
