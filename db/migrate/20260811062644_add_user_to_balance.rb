class AddUserToBalance < ActiveRecord::Migration[8.1]
  def change
    add_reference :balances, :user, type: :uuid, null: false, foreign_key: true
  end
end
