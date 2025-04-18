# app/serializers/team_serializer.rb
class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :members

  def members
    object.users.map do |user|
     role = object.memberships.find_by(user_id: user)&.role
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: role
      }
    end
  end
end
