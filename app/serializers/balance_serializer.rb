class BalanceSerializer < ActiveModel::Serializer
  include TimestampSerializer
  attributes :id, :value, :updated_at, :owner_id

  def owner_id
    "#{object.user_id}"
  end

  def updated_at
    "#{object.updated_at.strftime("%Y-%m-%d %H:%M:%S")}"
  end
end
