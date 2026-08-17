class AddBookAndAuthorToAuthorBooks < ActiveRecord::Migration[8.1]
  def change
    add_reference :author_books, :author, null: false, foreign_key: true
    add_reference :author_books, :book, null: false, foreign_key: true
  end
end
