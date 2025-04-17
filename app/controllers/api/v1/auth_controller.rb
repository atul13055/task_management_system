class Api::V1::AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:signup, :login]

  def signup
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      render json: {messages: 'User Created Successfully',data: UserSerializer.new(user), token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:data][:email])
    debugger # Check user object and params
    if user&.authenticate(params[:data][:password])
      token = JsonWebToken.encode(user_id: user.id)
      user.update(last_logged_in: Time.current)
      render json: { messages: 'Login Successful', data: UserSerializer.new(user), token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end


  private

  def user_params
    params.require(:data).permit(:name, :email, :password, :password_confirmation)
  end
end
