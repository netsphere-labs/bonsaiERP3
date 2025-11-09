
# $ rails new BonsaiErp --skip-active-storage --database=postgresql --javascript=esbuild --skip-bundle
# $ bundle config set --local path vendor/bundle
# $ bundle

source "https://rubygems.org"

# v3.3.1 では、ピンポイントで bootsnap が動かない.
ruby '>= 3.3.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
# "propshaft" 単体ではトランスパイルを行わない。TypeScript, Sass を使う場合は,
#   1) "sprockets-rails" か
#   2) "propshaft" + jsbundling-rails と cssbundling-rails 
# Rails 7: gem "sprockets-rails", "~> 3.5"  # Rails >=6.1
gem "propshaft"

# SASS 記法 (字下げを用いる) は廃れた. 今は SCSS 記法 (`{`〜`}` で囲む)。
# ライブラリは併せて sass.
# sass-rails 6.0.0 2019年8月
# 依存 "sass-rails" -> sassc-rails --> sprockets-rails 3.5.2
#                                  +-> sassc 2.4.0  # 中で LibSass を実行
# 移行先 1. dartsass-rails  sass バイナリを含む。importmap-rails 下での利用
#             依存 +-> sass-embedded -> google-protobuf
#        2. cssbundling-rails  npm sass を呼び出す. これがよい.
#        3. webpack の sass-loader
#gem "sass-rails", "~> 6.0"
gem "cssbundling-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
# vite を使う場合, 不要.
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
#gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
#gem "solid_cache"
#gem "solid_queue"
#gem "solid_cable"

if RUBY_VERSION != '3.3.1'
  # Reduces boot times through caching; required in config/boot.rb
  gem "bootsnap", require: false
end

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

#gem 'concurrent-ruby', '1.3.4'  # Pin to avoid Logger issues with newer versions
#gem 'logger', '~> 1.4'

# Temporarily adding compass-rails for backward compatibility during upgrade
# Removed compass-rails as it's not compatible with sass-rails 6.0
# gem 'compass-rails', '~> 3.1.0'

# [DISCONTINUED] Attributes on Steroids for Plain Old Ruby Objects
#gem 'virtus', '~> 2.0'

# v1.2.3: 2015年. 廃れた
#   AR: Model.where('created_at < ?', 2.weeks.ago)
#   squeel: Model.where { created_at < 2.weeks.ago }
# ActiveRecord を大胆にモンキーパッチしているため, 対応バージョンが必要
#gem 'squeel' # Better SQL queries

# Bootstrap5 で作るなら, `bootstrap_form` のほうがだいぶいい. 入れ替える
#gem 'simple_form', '~> 5.1'  # Compatible with Rails 6.0
gem 'bootstrap_form', '~> 5.4'

# Template engines
gem 'haml' 

#gem 'erubis', '~> 2.7.0'
# gem 'erb', '~> 2.2.0'

gem 'kaminari', '~> 1.2' # Pagination

# ActiveRecord Classes to encode in JSON
# v0.10.15  2024 Dec
# コントローラで `render json: ar_obj` と書くと, シリアライザクラスで事前定義し
# ていたフィールドだけを JSON で送信する.
#   `app/serializers/` 以下にシリアライザクラスを置く.
#   配列はどうするの? メソッドによって返したいフィールドが異なる場合は?
#   -> jbuilder でやったほうがいい
#gem 'active_model_serializers', '~> 0.10.15' 

#gem 'resubject' # Cool presenter

# v1.8 2024年4月
gem 'validates_email_format_of'#, '~> 1.5'

# Model クラスに `validates_lengths_from_database()` が生える.
# `validates_uniqueness_of` の追加クエリをなくす (performance improvement)
# "database_validations" gem も考慮に値する.
#   `db_belongs_to` method
gem 'validates_lengths_from_database'

# PostgreSQL hstore 拡張. Linux 側に postgresql-contrib パッケージが必要.
# Hstore accessor
#gem 'hstore_accessor'

# Adds typed jsonb backed fields to your ActiveRecord models.
# 固定フィールドを JSON にするのは本末転倒.
#gem 'jsonb_accessor', '~> 1.4'

gem 'dragonfly', '~> 1.4'

#gem "responders", "~> 3.0.0"  # Compatible with Rails 6.0

group :production do
  #gem 'newrelic_rpm', '~> 6.15.0'  # Compatible with Rails 6.0
  #gem 'bugsnag', '~> 6.24.0' # Report of errors
  #gem 'rack-cache', '~> 1.13.0', require: 'rack/cache'
end


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # A gem for generating test coverage results in your browser.
  gem "simplecov", require: false
  gem "simplecov-json", require: false

  # Generate test objects.
  # 6.3.0 and 6.4.0 have a bug https://github.com/thoughtbot/factory_bot_rails/issues/433
  # And now 6.4.1 and 6.4.2 break some things: https://github.com/bullet-train-co/bullet_train-core/issues/707
  gem "factory_bot_rails", "~> 6.5"
    
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  # コードベースをスキャンして、SQLインジェクションやクロスサイトスクリプティン
  # グ（XSS）のような一般的な問題を含む脆弱性を検出
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # rspec 8.x for Rails 8.0 or 7.2.
  # rspec 7.x for Rails 7.0/7.1.
  gem "rspec-rails", '~> 8.0'

  # A great debugger. not 'pry-rails' gem.
  gem "pry"
end


group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # 繰り返しエラーを吐く. コメントアウト
  #gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  # Open any sent emails in your browser instead of having to setup an SMTP trap.
  gem "letter_opener"

  #gem "better_errors", '~> 2.9.1'
  #gem "binding_of_caller", '~> 1.0.0'
  #gem "meta_request", '~> 0.7.3'
  #gem "rails_best_practices", '~> 1.23.0'
  # quiet_assets functionality is built into Rails 5+
  # gem "bullet", '~> 6.1.5'
  #gem "awesome_print", '~> 1.9.2'

  #gem 'listen', '~> 3.2.1' # Required for Rails 6.0 file watcher
end


group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.39"
  
  # Synchronize Capybara commands with client-side JavaScript and AJAX requests
  # to greatly improve system test stability. Only works on the Selenium Driver
  # though.
  gem "capybara-lockstep"

  # Selenium is the default default Capybara driver for system tests that ships
  # with Rails. Cuprite is an alternative driver that uses Chrome's native
  # DevTools protocol and offers improved speed and reliability, but only works
  # with Chrome. If you want to switch to Cuprite, you can comment out the
  # `selenium-webdriver` gem and uncomment the `cuprite` gem below.  
  gem "selenium-webdriver"
  # gem "cuprite"

  #gem "database_cleaner", '~> 2.0.1'  # Compatible with Rails 6.0
  #gem "shoulda-matchers", '~> 5.0.0', require: false  # Compatible with Rails 6.0
  #gem "valid_attribute", '~> 2.0.0'
  #gem "watchr", '~> 0.7'
  #gem "launchy", '~> 2.5.0'
  #gem 'rails-controller-testing', '~> 1.0.5'  # For assigns and assert_template in Rails 6.0
end

# Background processing
gem "sidekiq"

# Protect the API routes via CORS
# サブドメインで使うとき, CORS 設定が必要。See config/initializers/cors.rb
gem "rack-cors"


# Use Ruby hashes as readonly datasources for ActiveRecord-like models.
#gem "active_hash"

# do `bundle exec vite install`
# サブドメインで上手く動かせなかった. 剥がす
#gem "vite_rails"

# 各テナントを PostgreSQL のスキーマを使って完全に分ける
#   ros-apartment 3.2  rails >=6.1.0, < 8.1
gem "ros-apartment", "~> 3.2", require: 'apartment'

# 依存: "countries" gem
# `Money::Currency` と組み合わせる.
gem "country_select"

# authentication
gem "sorcery", ">= 0.17.0"

# authorization
gem "pundit", "~> 2.5"

# `error_messages_for`
gem 'dynamic_form', '>= 1.3.0'
