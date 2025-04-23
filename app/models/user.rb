class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password,
            confirmation: true,
            length: { minimum: 6, message: 'must be at least 6 characters long' }, allow_nil: true
  validates :password_confirmation, presence: true, if: -> { password.present? }
  validates :username, presence: true, uniqueness: true
  before_save { self.email = email.downcase }

  
  enum status: {
    available: 'available',
    busy: 'busy',
    suspended: 'suspended'
  }

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :created_teams, class_name: 'Team', foreign_key: 'creator_id'
  has_many :created_tasks, class_name: 'Task', foreign_key: 'creator_id'
  # has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assigned_user_id'
  # has_many :assigned_tasks, class_name: "Task", foreign_key: "assigned_user_id", dependent: :nullify
  has_many :teams_as_member, through: :memberships, source: :team, dependent: :nullify
  has_and_belongs_to_many :assigned_tasks, class_name: 'Task', join_table: 'tasks_users', foreign_key: 'user_id', dependent: :nullify


  has_one :user_otp, dependent: :destroy
  has_one :user_forgot_password_otp, dependent: :destroy



  def admin_of?(team)
    Membership.joins(:team).where(user_id: id, team_id: team.id, role: :admin).exists?
  end

  def member_of?(team)
    Membership.joins(:team).where(user_id: id, team_id: team.id).exists?
  end

  def locked?
    locked_at.present? && locked_at > 10.minutes.ago
  end

  def reset_failed_attempts
    update(failed_attempts: 0, locked_at: nil, active: true)
  end

  def lock_account
    update(active: false, locked_at: Time.current)
  end

end
