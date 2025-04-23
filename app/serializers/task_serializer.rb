# class TaskSerializer < ActiveModel::Serializer
#   attributes :id, :title, :description, :status, :priority, :due_date, :team

#   # belongs_to :team, serializer: TeamSerializer
#   def team
#       {
#         id: object.team.id,
#         name: object.team.name,
#         creator_id: object.team.creator_id
#       }
#     end
#   belongs_to :assigned_user, serializer: UserSerializer
# end

class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :priority, :due_date, :team, :created_at, :updated_at

  has_many :assigned_users, serializer: UserSerializer

  def team
    {
      id: object.team.id,
      name: object.team.name,
      creator_id: object.team.creator_id
    }
  end
end
