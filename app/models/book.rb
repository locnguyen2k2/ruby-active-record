class Book < ApplicationRecord
  belongs_to :author, class_name: 'User::Author', optional: true
  User.all
end