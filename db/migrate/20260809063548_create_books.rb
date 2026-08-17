class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :description
      t.datetime :published_at

      t.timestamps
    end
  end
end
