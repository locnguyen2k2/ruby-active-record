module ExceptionResponse
  extend ActiveSupport::Concern
  included do
    rescue_from Errors::AppException do |e|
      render json: {
        message: e.message,
        success: false
      }, status: e&.status ||= 200
    end
  end
end
