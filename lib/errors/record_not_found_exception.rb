module Errors
  class RecordNotFoundException < BusinessException
    def initialize(exception_args = MessageData::RECORD_NOT_FOUND)
      super(exception_args)
    end
  end
end
