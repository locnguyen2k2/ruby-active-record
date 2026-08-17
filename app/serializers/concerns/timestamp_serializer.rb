module TimestampSerializer
  extend ActiveSupport::Concern
  include Timestamp

  included do
    attributes :created_at, :updated_at

    def created_at
      Timestamp.format_datetime object.created_at
    end

    def updated_at
      Timestamp.format_datetime object.updated_at
    end
  end
end
