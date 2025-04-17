class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :status, default: 0
      t.integer :priority, default: 1
      t.datetime :due_date
      t.references :team, foreign_key: true
      t.references :creator, foreign_key: { to_table: :users }
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end