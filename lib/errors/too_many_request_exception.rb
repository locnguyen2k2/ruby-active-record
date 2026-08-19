module Errors
  class TooManyRequestException < BusinessException
    def initialize
      super(MessageData::TOO_MANY_REQUEST)
    end
  end
end
