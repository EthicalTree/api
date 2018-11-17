module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from Exceptions::BadRequest,       with: :bad_request
    rescue_from Exceptions::Unauthorized,     with: :unauthorized
    rescue_from Exceptions::PaymentRequired,  with: :payment_required
    rescue_from Exceptions::Forbidden,        with: :forbidden
    rescue_from Exceptions::NotFound,         with: :not_found
    rescue_from Exceptions::Conflict,         with: :conflict

    def bad_request(e)                      error e, 400 end

    def unauthorized(e)                     error e, 401 end

    def payment_required(e)                 error e, 402 end

    def forbidden(e)                        error e, 403 end

    def not_found(e)                        error e, 404 end

    def conflict(e)                         error e, 409 end

    def error e, status
      render json: { message: e.message }, status: status
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from AccessGranted::AccessDenied do |e|
      json_response({ message: e.message }, :unauthorized)
    end
  end
end
