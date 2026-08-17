# EachValidator: Handle for specific attribute by attribute, value params
class UuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add :attribute, "#{value} is not valid UUID" unless UUID.validate(value)
  end
end
