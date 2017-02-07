source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'foreman'
gem 'exception_notification'

gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

# Extra Libraries
gem 'bootstrap-sass'
gem 'haml'
gem 'aws-sdk', '~> 2'
gem 'httparty'
gem 'dotenv-rails'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'factory_girl_rails'
  gem 'mocha'
  gem 'faker'
  gem 'shoulda'
  gem 'byebug', platform: :mri
end

group :development do
  gem 'thin'
  #gem 'spring'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'capistrano', '~> 3.7.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-chruby'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  #gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'unicorn'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
