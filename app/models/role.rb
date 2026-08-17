class Role < ApplicationRecord
  include CommonInfoValidation

  has_many :permission, through: :role_permission
  has_many :role_permission
  has_many :users

  scope :available_role_by_slug, ->(slug = "user") { where(slug: slug, enable: true).first  }
end
