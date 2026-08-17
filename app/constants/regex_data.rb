module RegexData
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  PHONE_REGEX = /\A\d{10}\z/
  USERNAME_REGEX = /\A[a-zA-Z][a-zA-Z0-9_]*\z/
  SLUG_REGEX= /^[a-z0-9-]+$/
end
