class RoleSerializer < ActiveModel::Serializer
   include TimestampSerializer
   attributes :id, :label, :slug
end
