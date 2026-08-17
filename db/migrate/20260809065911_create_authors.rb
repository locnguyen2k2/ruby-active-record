class CreateAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :authors do |t|
      t.belongs_to :users, null: false, foreign_key: true
      t.string :nick_name
      t.string :started_at
      t.string :career_started_at

      t.timestamps
    end
  end
end
