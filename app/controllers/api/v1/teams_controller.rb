class Api::V1::TeamsController < ApplicationController

  before_action :set_team, only: [:invite, :members]

  def index
    @teams = current_user.teams.includes(:memberships).page(params[:page]).per(params[:per_page] || 10)

    render json: @teams,
           each_serializer: TeamSerializer,
           scope: current_user,
           meta: {
             current_page: @teams.current_page,
             total_pages: @teams.total_pages,
             total_count: @teams.total_count
           },
           adapter: :json
  end


  def create
    @team = Team.new(team_params)
    @team.creator = current_user

    if @team.save
      @team.memberships.create!(user: current_user, role: :admin)

      render json: {
        id: @team.id,
        name: @team.name,
        creator_id: @team.creator_id,
        role: 'admin'
      }, status: :created
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def invite
    unless current_user.admin_of?(@team)
      return render json: { error: 'Only admins can invite user' }, status: :forbidden
    end

    user = User.find_by(email: params[:email])
    if user.nil?
      return render json: { error: 'User not found' }, status: :not_found
    end

    if @team.users.include?(user)
      return render json: { error: 'User is already a member of team' }, status: :unprocessable_entity
    end

    if @team.memberships.create(user: user, role: params[:role] || :member)
      render json: { message: 'User invited successfully' }
    else
      render json: { error: 'Invitation faiiled' }, status: :unprocessable_entity
    end
  end

  def members
    unless current_user.member_of?(@team)
      return render json: { error: 'You are not member of this team' }, status: :forbidden
    end

    team_members = @team.memberships.includes(:user).map do |membership|
      {
        id: membership.user.id,
        name: membership.user.name,
        email: membership.user.email,
        role: membership.role
      }
    end

    render json: team_members
  end


  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
