class EmailValidator < ActiveModel::Validator
  def validate(record)
    if record.email.blank?
      record.errors.add :email, "Email is empty!"
      return
    end
    if !URI::MailTo::EMAIL_REGEXP.match?(record.email)
      record.errors.add :email, "Email is not valid!"
    end
  end
end