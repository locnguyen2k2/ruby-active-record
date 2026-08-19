class RolePermission < ApplicationRecord
  belongs_to :role
  # belongs_to :role, dependent: :destroy # object is destroyed => destroy will be called on associated objects
  # belongs_to :role, dependent: :delete
  belongs_to :permission
  before_destroy :before_destroy_callback

  def before_destroy_callback
    Rails.logger.warn("RolePermission model #{id} will be destroyed")
  end
end
