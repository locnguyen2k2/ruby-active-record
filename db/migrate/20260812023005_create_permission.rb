class CreatePermission < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :slug
      t.string :label
      t.boolean :enable

      t.timestamps
    end
  end
end
