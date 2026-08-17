class SlugValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, "is required!" if value.blank?
    record.errors.add attribute, "length require in range: #{3} to #{12}" if value.length < 3 || value.length > 12
    record.errors.add attribute, "is invalid!" unless RegexData::SLUG_REGEX.match?(value)
  end
end
