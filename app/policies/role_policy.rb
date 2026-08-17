class RolePolicy < ApplicationPolicy
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
        scope.where(created_by: user.id)
      end
    end
  end
end
