class Api::V1::UsersController < ApplicationController

  def profile
    if @current_user
      render json: { data: ProfileSerializer.new(@current_user) }, status: :ok
    else
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end
end

