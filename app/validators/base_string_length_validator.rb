# Validator: Handle for attributes
class BaseStringLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :record, "Label is required" && return if value.blank?
    record.errors.add :record, "Max length of this field is 255" && return if value.length > 255
  end
end
