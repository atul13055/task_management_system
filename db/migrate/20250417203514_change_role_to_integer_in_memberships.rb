class ChangeRoleToIntegerInMemberships < ActiveRecord::Migration[7.0]
  def change
    change_column :memberships, :role, :integer, default: 0
  end
end
