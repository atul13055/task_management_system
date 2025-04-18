class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team
  
  enum role: { member: 0, admin: 1 }
  validates :role, presence: true

  validates :user_id, uniqueness: { scope: :team_id }
  validate :creator_is_admin

  private
  # Teamm creator must be admin
  def creator_is_admin
    if team.creator_id == user_id && !admin?
      errors.add(:role, "Team creator must be admin")
    end
  end
end
