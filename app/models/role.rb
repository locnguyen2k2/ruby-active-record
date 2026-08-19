class Role < ApplicationRecord
  include CommonInfoValidation

  has_many :permission, through: :role_permission
  has_many :role_permission, dependent: :destroy # all the associated objects to also be destroyed
  has_many :users
  before_destroy :before_destroy_callback

  def before_destroy_callback
    Rails.logger.warn("Role model #{id} will be destroyed")
  end

  scope :available_role_by_slug, ->(slug = "user") { where(slug: slug, enable: true).first  }
end
