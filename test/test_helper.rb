ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  track_files "{app,lib}/**/*.rb"
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'

Rails.application.load_seed

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def authorize user
    token = Knock::AuthToken.new(payload: { sub: user.id  }).token
    request.headers.merge!({
      'Authorization': "Bearer #{token}"
    })
  end
end
