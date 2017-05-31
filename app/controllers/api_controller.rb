class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable
end
