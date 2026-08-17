class AddCreatedBy < ActiveRecord::Migration[8.1]
 def change
    add_column :users, :created_by, :uuid
    add_column :wallets, :created_by, :uuid
    add_column :balances, :created_by, :uuid
    add_column :permissions, :created_by, :uuid
    add_column :roles, :created_by, :uuid
    add_column :role_permissions, :created_by, :uuid
  end
end
