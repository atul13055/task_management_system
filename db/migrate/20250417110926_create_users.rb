class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :mobile
      t.string :departement
      t.string :email
      t.string :password_digest
      t.datetime :last_logged_in

      t.timestamps
    end
  end
end
