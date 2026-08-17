class CreateRole < ActiveRecord::Migration[8.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :slug
      t.string :label
      t.boolean :enable

      t.timestamps
    end
  end
end
