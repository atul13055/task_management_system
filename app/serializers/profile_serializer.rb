class ProfileSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :email,
             :mobile,
             :username,
             :status,
             :designation,
             :skills,
             :last_logged_in,
             :created_at,
             :updated_at

  def last_logged_in
    object.last_logged_in.strftime('%Y-%m-%d %H:%M:%S') if object.last_logged_in
  end
end
