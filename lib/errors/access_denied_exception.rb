module Errors
  class AccessDeniedException < BusinessException
    def initialize(exception_args = MessageData::ACCESS_DENIED)
      super(exception_args)
    end
  end
end
