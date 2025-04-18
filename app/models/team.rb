class Team < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :tasks, dependent: :destroy

  validates :name, presence: true

  def add_member(user, role: :member)
    memberships.create!(user: user, role: role)
  end

  def remove_member(user)
    memberships.find_by(user: user)&.destroy
  end

  def admin_users
    memberships.admin.map(&:user)
  end
end
