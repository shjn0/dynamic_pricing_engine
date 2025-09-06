source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 1.2025", ">= 1.2025.2", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", ">= 1.18.6", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.15", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 7.1", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", "~> 1.1", require: false

  gem "database_cleaner-mongoid", "~> 2.0", ">= 2.0.1"
  gem "dotenv", "~> 3.1", ">= 3.1.8"
  gem "factory_bot_rails", "~> 6.5", ">= 6.5.1"
  gem "rspec-rails", "~> 8.0", ">= 8.0.2"
  gem "simplecov", "~> 0.22.0"
  gem "webmock", "~> 3.25", ">= 3.25.1"
end

gem "csv", "~> 3.3", ">= 3.3.5"
gem "jsonapi-serializer", "~> 2.2"
gem "kaminari-mongoid", "~> 1.0", ">= 1.0.2"
gem "mongoid", "~> 9.0", ">= 9.0.7"
gem "ostruct", "~> 0.6.3"
gem "sidekiq", "~> 8.0", ">= 8.0.7"
gem "sidekiq-cron", "~> 2.3", ">= 2.3.1"
