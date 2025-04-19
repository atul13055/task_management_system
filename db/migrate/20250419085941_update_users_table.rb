class UpdateUsersTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :departement, :string
    add_column :users, :username, :string
    add_column :users, :status, :string, default: "available"
    add_column :users, :designation, :string 
    add_column :users, :experience, :string
    add_column :users, :skills, :string
    add_column :users, :location, :string 
  end
end
