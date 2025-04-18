class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status, :priority, :due_date

  belongs_to :team, serializer: TeamSerializer
  belongs_to :assigned_user, serializer: UserSerializer
end
