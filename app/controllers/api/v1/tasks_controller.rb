class Api::V1::TasksController < ApplicationController
  load_and_authorize_resource :team, only: [:index, :create]
  load_and_authorize_resource :task, through: :team, only: [:index, :create]
  load_and_authorize_resource except: [:index, :create]

  before_action :set_team, only: [:index, :create]
  before_action :set_task, only: [:show, :update, :assign, :destroy]

  def index
    @tasks = @team.tasks.includes(:assigned_users, team: :users)
                   .order(created_at: :desc)

    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(priority: params[:priority]) if params[:priority].present?
    @tasks = @tasks.where(due_date: params[:due_date]) if params[:due_date].present?

    @tasks = @tasks.page(params[:page]).per(params[:per_page] || 10)

    render json: @tasks,
           each_serializer: TaskSerializer,
           meta: {
             current_page: @tasks.current_page,
             total_pages: @tasks.total_pages,
             total_count: @tasks.total_count
           },
           adapter: :json
  end

  def show
    unless @task.assigned_users.exists?(id: current_user.id) || @task.creator_id == current_user.id
      return render json: { error: 'You are not authorized to view this task' }, status: :forbidden
    end

    render json: @task.as_json
  end

  def create
    authorize! :manage, @team

    @task = @team.tasks.build(task_params.except(:assigned_user_ids))
    @task.creator = current_user
    @task.assigned_users = @team.users.where(id: task_params[:assigned_user_ids]) if task_params[:assigned_user_ids].present?

    if @task.save
      render json: @task, status: :created
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def update
    if @task.assigned_users.exists?(id: current_user.id) &&
       current_user.memberships.find_by(team_id: @task.team_id)&.role == 'member'
       
      if (task_params.keys - ['status']).any?
        return render json: { error: 'You can only update status of your task' }, status: :forbidden
      end
    else
      authorize! :manage, @task
    end

    if @task.update(task_params.except(:assigned_user_ids))
      render json: @task.as_json
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def assign_users
    authorize! :manage, @task

    new_user_ids = params[:assigned_user_ids].map(&:to_i)
    old_user_ids = @task.assigned_users.pluck(:id)

     #Ensure all assigned users are team members
      unless @task.team.users.exists?(id: new_user_ids)
        return render json: { error: 'All assigned users must be team members' }, status: :unprocessable_entity
      end

      if new_user_ids.include?(current_user.id.to_s)
        return render json: { error: 'You cannot assign a task to yourself' }, status: :unprocessable_entity
      end


    # Final unique list of assigned user IDs
    merged_ids = (old_user_ids + new_user_ids).uniq

    # Set previous_assigned_user_ids manually to detect new ones later
    @task.previous_assigned_user_ids = old_user_ids

    # Assign merged users
    @task.assigned_users = @task.team.users.where(id: merged_ids)

    if @task.save
      render json: {
        message: "Users assigned successfully",
        task: @task.as_json(methods: [:assigned_user_details])
      }, status: :ok
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def remove_users
    authorize! :manage, @task

    user_ids_to_remove = params[:remove_user_ids].map(&:to_i)

    # Only remove users who are actually assigned
    users_to_remove = @task.assigned_users.where(id: user_ids_to_remove)

    if users_to_remove.empty?
      return render json: { error: "No valid users to remove" }, status: :unprocessable_entity
    end

    # Remove them from task
    @task.assigned_users -= users_to_remove

    if @task.save

      users_to_remove.each do |user|
        TaskMailer.task_unassigned(@task, user).deliver_later if user.email.present?
      end
      render json: {
        message: "Users removed successfully",
        removed_users: users_to_remove.map { |u| { id: u.id, name: u.name } },
        task: @task.as_json
      }, status: :ok
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end


  def destroy
    authorize! :manage, @task
    @task.destroy
    render json: { message: 'Task deleted successfully' }, status: :ok
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, assigned_user_ids: [])
  end
end
