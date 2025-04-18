class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    team_ids = user.teams.pluck(:id)
    admin_team_ids = user.memberships.select { |m| m.admin? }.map(&:team_id)

    # Admins  manage everything in their teams
    can :manage, Team, id: admin_team_ids
    can :manage, Membership, team_id: admin_team_ids
    can :manage, Task, team_id: admin_team_ids

    # Members  read their teams
    can :read, Team, id: team_ids
    can :update, Task, assigned_user_id: user.id
    can :read, Task, assigned_user_id: user.id
  end
end
