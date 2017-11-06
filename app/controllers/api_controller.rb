class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable

  def not_found
    render status: 404
  end
end
