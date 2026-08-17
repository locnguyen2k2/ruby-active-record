module Errors
  class BusinessException < AppException
    def initialize(exception_args)
      super(exception_args[:message], status: exception_args[:status])
    end
  end
end
