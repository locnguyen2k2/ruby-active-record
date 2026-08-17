module Errors
  class AppException < StandardError
    attr_reader :status, :code

    def initialize(message, status: :unprocessable_entity)
      @status = status
      super(message)
    end
  end
end
