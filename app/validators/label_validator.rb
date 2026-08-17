class LabelValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :label, "is required" if record.label.blank?
    record.errors.add :label, "allowed max length of this field is 255" if record.label.length > 255
  end
end
