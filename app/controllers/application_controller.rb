class ApplicationController < ActionController::Base

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end
end

class APIController < ActionController::API
  include Response
  include ExceptionHandler
  include Knock::Authenticable
end

class SecuredController < APIController
  before_action :authenticate_user
end
