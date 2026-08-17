class WalletPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.role.slug == RoleData::ADMIN
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def show?
    user.role.slug == RoleData::ADMIN || user.id == record.user_id
  end

  def update?
    user.id == record.user_id
  end
end
