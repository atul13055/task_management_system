class AddLoginAttemptsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :failed_attempts, :integer
    add_column :users, :locked_at, :datetime
  end
end
