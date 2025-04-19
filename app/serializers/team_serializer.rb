class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :members

  def members
    roles_by_user_id = object.memberships.index_by(&:user_id)

    object.users.map do |user|
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: roles_by_user_id[user.id]&.role
      }
    end
  end
end
