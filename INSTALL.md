
# BonsaiERP Installation Guide (Updated April 2025)


## System Requirements

 - Ruby 3.3.x (for Rails 8.0 upgrade)
 - Rails 8.0.x 
 - PostgreSQL 14.0 or higher
 - PostgreSQL development headers (`libpq-dev`), `postgresql-contrib` to enable **hstore**
 - Node.js v18.19 or higher
 - redis v8.0
 

### Other Dependencies
- ImageMagick (for image processing)
- Git



## Development Environment Setup

### 1. Install Ruby using RVM or rbenv

```bash
# Using RVM
\curl -sSL https://get.rvm.io | bash -s stable
rvm install ruby-2.6.4
rvm use ruby-2.6.4 --default

# Using rbenv
brew install rbenv ruby-build
rbenv install 2.6.4
rbenv global 2.6.4
```

### 2. Install PostgreSQL

#### macOS
```bash
brew install postgresql@14
brew services start postgresql@14
```

#### Ubuntu
```bash
sudo apt update
sudo apt install postgresql-14 postgresql-contrib-14 libpq-dev
```

### 3. Install Node.js and Yarn

#### macOS
```bash
brew install node yarn
```

#### Ubuntu
```bash
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

### 4. Install ImageMagick

#### macOS
```bash
brew install imagemagick
```

#### Ubuntu
```bash
sudo apt-get install imagemagick
```



## Application Setup

### 1. Clone the repository
```bash
git clone https://github.com/netsphere-labs/bonsaiERP3.git
cd bonsaiERP3
```

### 2. Install dependencies
```bash
bundle 
yarn 
```

### 3. Configure the database
Copy `config/database.yml.sample` to `database.yaml` and edit it with the following content:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: bonsai_development
  username: your_postgres_username
  password: your_postgres_password
  host: localhost

test:
  <<: *default
  database: bonsai_test
  username: your_postgres_username
  password: your_postgres_password
  host: localhost

production:
  <<: *default
  database: bonsai_production
  username: bonsai_data
  password: <%= ENV['BONSAI_DATABASE_PASSWORD'] %>
  host: localhost
```

### 4. Set up environment variables
Create a file `config/app_environment_variables.rb` with the following content:

●●これ, どこで使われている?

```ruby
ENV['SECRET_KEY_BASE'] = 'your_secret_key_base'
ENV['MANDRILL_API_KEY'] = 'your_mandrill_api_key'
```

### 5. Initialize the database

By `postgres` user,

```shell
$ createdb --owner rails --encoding UTF-8 bonsai_erp_development
$ createdb --owner rails --encoding UTF-8 bonsai_erp_test
```

If you use tenants, set `USE_SUBDOMAIN = true` in `config/initializers/constants.rb`

```bash
rails db:migrate
rails db:seed
```

Sample login email and password are generated.

If you are in Ubuntu or Debian, add something like this to your `/etc/hosts`
file.
テナント選択については, `config/initializers/apartment.rb` ファイルを見てください。
```
127.0.0.1   mycompany.localhost.bom  company2.localhost.bom
```



### 6. Precompile assets (for production)
```bash
rails assets:precompile
```



### 7. Start the development server

On another terminal,

```shell
$ redis-server
```

And run!

```shell
$ foreman start -f Procfile.dev
```




## Production Deployment

### 1. Configure the web server (Nginx or Apache)

#### Nginx with Passenger
Install Passenger and Nginx:

```bash
gem install passenger
passenger-install-nginx-module
```

Configure Nginx:

```nginx
server {
  listen 80;
  server_name your-domain.com;
  root /path/to/bonsaiERP/public;
  passenger_enabled on;
  passenger_ruby /path/to/ruby;
  
  # Rails asset pipeline
  location ~ ^/assets/ {
    expires max;
    add_header Cache-Control public;
  }
}
```

#### Apache with Passenger
Install Passenger for Apache:

```bash
gem install passenger
passenger-install-apache2-module
```

Configure Apache:

```apache
<VirtualHost *:80>
  ServerName your-domain.com
  DocumentRoot /path/to/bonsaiERP/public
  
  PassengerRuby /path/to/ruby
  
  <Directory /path/to/bonsaiERP/public>
    Allow from all
    Options -MultiViews
    Require all granted
  </Directory>
</VirtualHost>
```

### 2. Set up environment variables for production
Make sure to set all required environment variables in your production environment.

### 3. Database setup for production
```bash
RAILS_ENV=production rails db:setup
RAILS_ENV=production rails bonsai:create_data
```

## Upgrading to Rails 8.0 (Future)

When upgrading to Rails 8.0, the following additional requirements will be needed:

1. Ruby 3.3.0 or higher
2. Node.js 16.0 or higher
3. Propshaft for asset pipeline (replacing Sprockets)
4. Tailwind CSS for styling
5. PostgreSQL 16.0 or higher (recommended)

The upgrade process will involve:
1. Updating Ruby version
2. Updating Rails version incrementally (6.0 → 6.1 → 7.0 → 7.1 → 8.0)
3. Replacing Sprockets with Propshaft
4. Migrating from existing CSS to Tailwind CSS
5. Converting CoffeeScript to modern JavaScript

See the TODO.md file for a detailed upgrade plan.
