class UserSerializer < ActiveModel::Serializer
    # attributes :id, :email, :last_logged_in, :created_at, :updated_at
  attributes :id, :name, :email, :username, :active, :is_verified, :last_logged_in
end
