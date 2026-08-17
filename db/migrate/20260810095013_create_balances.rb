class CreateBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :balances, id: :uuid do |t|
      t.belongs_to :wallet, null: false, foreign_key: true
      t.float :value
      t.boolean :enable

      t.timestamps
    end
  end
end
