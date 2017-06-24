source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
gem 'mysql2'
gem 'puma', '~> 3.7.0'
gem 'exception_notification'
gem 'daemons'

gem 'jbuilder', '~> 2.5'
gem 'aws-sdk', '~> 2'
gem 'knock'
gem 'rack-cors', require: 'rack/cors'
gem 'haml-rails'

# Extra Libraries
gem 'httparty'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'geokit-rails'
gem 'fog-aws'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_girl_rails'
  gem 'rails-controller-testing'
  gem 'mocha'
  gem 'faker'
  gem 'shoulda'
  gem 'pry'
  gem 'pry-rails'
  gem 'byebug'
  gem 'pry-byebug', require: false
end

group :development do
  gem 'thin'
  gem 'spring'
  gem 'capistrano', '~> 3.7.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-chruby'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring-watcher-listen'
end

group :production do
  gem 'unicorn'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
