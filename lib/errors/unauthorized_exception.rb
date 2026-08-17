module Errors
  class UnauthorizedException < BusinessException
    def initialize(exception_args = MessageData::UNAUTHORIZED)
      super(exception_args)
    end
  end
end
