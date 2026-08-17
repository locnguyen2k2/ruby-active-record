class AddEnableToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :enable, :boolean
  end
end
