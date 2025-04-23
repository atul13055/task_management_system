class CreateJoinTableTasksUsers < ActiveRecord::Migration[7.0]
  def change
    create_join_table :tasks, :users do |t|
      t.index :task_id
      t.index :user_id
      t.index [:task_id, :user_id], unique: true
    end
  end
end
