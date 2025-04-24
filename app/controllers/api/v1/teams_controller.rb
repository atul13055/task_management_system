class Api::V1::TeamsController < ApplicationController
  load_and_authorize_resource except: [:members, :invite, :inviteable_users]
  before_action :set_team, only: [:members, :invite, :inviteable_users]

  def index
    @teams = @teams.page(params[:page]).per(params[:per_page] || 10)

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

def inviteable_users
  authorize! :manage, @team

  users = User.where(active: true, is_verified: true)
              .where.not(id: @team.user_ids)

  admin_user_ids = @team.team_users.where(role: 'admin').pluck(:user_id)
  users = users.where.not(id: admin_user_ids)

  users = users.where(status: params[:status]) if params[:status].present?
  users = users.where(designation: params[:designation]) if params[:designation].present?

  if params[:search].present?
    keyword = "%#{params[:search].downcase}%"
    users = users.where("LOWER(name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(username) LIKE ?", keyword, keyword, keyword)
  end

  # Pagination
  users = users.page(params[:page]).per(params[:per_page] || 10)

  render json: users,
         each_serializer: InviteableUserSerializer,
         meta: {
           current_page: users.current_page,
           total_pages: users.total_pages,
           total_count: users.total_count
         },
         adapter: :json
end


  def invite
    authorize! :manage, @team

    user = User.find_by(email: params[:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    if @team.users.include?(user)
      return render json: { error: 'User is already a member of the team' }, status: :unprocessable_entity
    end

    if @team.memberships.create(user: user, role: params[:role] || :member)
      render json: { message: 'User invited successfully' }
    else
      render json: { error: 'Invitation failed' }, status: :unprocessable_entity
    end
  end

  def members
    authorize! :read, @team

    team_members = @team.memberships.includes(:user).map do |membership|
      {
        id: membership.user.id,
        name: membership.user.name,
        email: membership.user.email,
        role: membership.role
      }
    end

    render json: {
      team: {
        id: @team.id,
        name: @team.name,
        created_at: @team.created_at
      },
      members: team_members
    }
  end


  private

  def set_team
    @team = Team.find(params[:team_id] || params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
