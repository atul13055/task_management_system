class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password,
            confirmation: true,
            length: { minimum: 6, message: 'must be at least 6 characters long' }

  validates :password_confirmation, presence: true, if: -> { password.present? }
  has_many :memberships
  has_many :teams, through: :memberships
  has_many :created_tasks, class_name: 'Task', foreign_key: 'creator_id'
  has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_user_id'
end
