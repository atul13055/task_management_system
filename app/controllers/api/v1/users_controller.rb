class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy, :profile, :assigned_teams]

  def profile
    if @user
      render json: { data: ProfileSerializer.new(@current_user) }, status: :ok
    else
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def assigned_teams
    user_teams = @current_user.teams

    if user_teams.present?
      render json: { data: user_teams }, status: :ok
    else
      render json: { error: 'No teams assigned to you' }, status: :not_found
    end
  end

  def assigned_tasks
    tasks = @current_user.assigned_tasks

    if tasks.present?
      render json: { data: tasks }, status: :ok
    else
      render json: { error: 'No tasks assigned to you' }, status: :not_found
    end
  end

  def update
    if @user.update(user_update_params)
      render json: { message: 'Profile updated successfully', data: ProfileSerializer.new(@user) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      render json: { message: 'Account deleted successfully' }, status: :ok
    else
      render json: { error: 'Failed to delete account' }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = @current_user
  end

  def user_update_params
    params.require(:data).permit(:name, :username, :email, :designation, :experience, :skills, :location, :status)
  end
end
