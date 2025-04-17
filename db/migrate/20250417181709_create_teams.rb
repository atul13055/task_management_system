class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name
       t.references :creator, foreign_key: { to_table: :users } 

      t.timestamps
    end
  end
end
