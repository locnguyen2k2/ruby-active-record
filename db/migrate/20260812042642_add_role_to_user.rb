class AddRoleToUser < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :role, type: :uuid, null: true, foreign_key: true
  end
end
