class RenameRoleToUserRoleInMemberships < ActiveRecord::Migration[7.0]
  def change
      rename_column :memberships, :role, :user_role
  end
end
