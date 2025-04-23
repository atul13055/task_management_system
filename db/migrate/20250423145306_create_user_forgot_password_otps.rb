class CreateUserForgotPasswordOtps < ActiveRecord::Migration[7.0]
  def change
    create_table :user_forgot_password_otps do |t|
      t.references :user, null: false, foreign_key: true
      t.string :otp
      t.datetime :expires_at

      t.timestamps
    end
  end
end
