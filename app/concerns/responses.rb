module Responses
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

  module Paginator
    extend ActiveSupport::Concern
      included do
        attributes :paginated
        # def paginated
        # Paginated.new
        # end
      end


    # class Paginated < PaginationSerializer
    # end
  end
end
