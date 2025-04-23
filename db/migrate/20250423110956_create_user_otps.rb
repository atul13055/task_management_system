class CreateUserOtps < ActiveRecord::Migration[6.0]
  def change
    create_table :user_otps do |t|
      t.references :user, null: false, foreign_key: true
      t.string :otp, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
  end
end
