  class UserSerializer < ActiveModel::Serializer
    include TimestampSerializer
    attributes :id, :full_name,  :role
    attribute :wallets, if: :include_wallets?

    def full_name
      "#{object.first_name} #{object.last_name}"
    end

    def role
      user_role = roles.detect { |r| r.id == object.role_id } || object.role
      RoleSerializer.new(user_role).attributes
    end

    def wallets
      object.wallets.map do |wallet|
        WalletSerializer.new(wallet).attributes
      end
    end

    def include_wallets?
      include && include[:wallets]
    end

    private
    def include
      scope[:include]
    end

    def roles
      scope && scope[:roles] ? scope[:roles] : []
    end
  end
