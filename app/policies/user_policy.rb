class UserPolicy < ApplicationPolicy
  class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        raise Errors::UnauthorizedException unless user
        @user = user
        @scope = scope
      end

      def resolve
        if user.role&.slug == RoleData::ADMIN
          scope.all
        else
          scope.where(id: user.id)
        end
      end
  end

  def profile?
    record.id == user.id
  end

  def show?
   user.role.slug == RoleData::ADMIN || record.id == user.id
  end

  def update?
   record.id == user.id
  end
end
