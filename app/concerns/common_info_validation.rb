module CommonInfoValidation
  extend ActiveSupport::Concern
  included do
    validates_with LabelValidator
    validates :slug, slug: true
  end
end
