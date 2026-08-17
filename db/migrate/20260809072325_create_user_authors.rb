class CreateUserAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :user_authors do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
