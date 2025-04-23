class UpdateForeignKeysOnDeleteToNullify < ActiveRecord::Migration[7.0]
  def change
    # Remove the existing foreign key constraints
    remove_foreign_key :memberships, :users
    remove_foreign_key :tasks, :users, column: :assigned_user_id
    remove_foreign_key :tasks, :users, column: :creator_id
    remove_foreign_key :teams, :users, column: :creator_id

    # Add foreign key constraints with `on_delete: :nullify`
    add_foreign_key :memberships, :users, on_delete: :nullify
    add_foreign_key :tasks, :users, column: :assigned_user_id, on_delete: :nullify
    add_foreign_key :tasks, :users, column: :creator_id, on_delete: :nullify
    add_foreign_key :teams, :users, column: :creator_id, on_delete: :nullify
  end
end
