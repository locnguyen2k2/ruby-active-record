class Permission < ApplicationRecord
  include CommonInfoValidation
  has_many :Role, through: :role_permission
  has_many :Role

  after_initialize do
    self.enable ||= true
  end
end
