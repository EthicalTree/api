class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
