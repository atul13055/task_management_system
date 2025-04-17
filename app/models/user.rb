class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password,
            confirmation: true,
            length: { minimum: 6, message: 'must be at least 6 characters long' }

  validates :password_confirmation, presence: true, if: -> { password.present? }
   has_many :created_teams, class_name: 'Team', foreign_key: 'creator_id'
end
