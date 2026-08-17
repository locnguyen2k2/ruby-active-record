class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets, id: :uuid do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :label
      t.text :description
      t.boolean :enable

      t.timestamps
    end
  end
end
