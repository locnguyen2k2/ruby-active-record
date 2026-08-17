class Author < ApplicationRecord
  has_many :books, class_name: 'Book', dependent: :destroy
  belongs_to :user, class_name: 'User', optional: true
end