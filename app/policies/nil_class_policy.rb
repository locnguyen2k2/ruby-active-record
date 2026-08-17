class NilClassPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      raise Errors::BusinessException.new(MessageData::UNAUTHORIZED)
    end
  end

  def show?
    false
  end
end
