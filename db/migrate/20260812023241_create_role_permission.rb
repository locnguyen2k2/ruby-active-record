class CreateRolePermission < ActiveRecord::Migration[8.1]
  def change
    create_table :role_permissions do |t|
      t.references :role, type: :uuid, null: false, foreign_key: true
      t.references :permission, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
