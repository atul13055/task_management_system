class InviteableUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :email, :status, :designation, :skills
end
