class WalletSerializer < ActiveModel::Serializer
  include TimestampSerializer

  attributes :id, :label, :owner_id, :created_at
  attribute :balances, if: :include_balances?

def include
  scope ? scope[:include] : nil
end

def include_balances?
  include && include[:balances]
end

  def owner_id
    object.user_id
  end

  def created_at
    "#{object.created_at.strftime("%Y-%m-%d %H:%M:%S")}"
  end

  def balances
    balances = object.balances
    balances.map do |balance|
     BalanceSerializer.new(balance).attributes
    end
  end
end
