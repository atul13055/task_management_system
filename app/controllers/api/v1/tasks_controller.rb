class Api::V1::TasksController < ApplicationController
  load_and_authorize_resource :team, only: [:index, :create]
  load_and_authorize_resource :task, through: :team, only: [:index, :create]
  load_and_authorize_resource except: [:index, :create]

  before_action :set_team, only: [:index, :create]
  before_action :set_task, only: [:show, :update, :assign, :destroy]

  def index
    @tasks = @team.tasks.includes(:assigned_user, team: :users)
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
    unless @task.assigned_user_id == current_user.id || @task.creator_id == current_user.id
      return render json: { error: 'You are not authorized to view this task' }, status: :forbidden
    end

    render json: @task.as_json

  end

  def create
    authorize! :manage, @team

    @task = @team.tasks.build(task_params.except(:assigned_user_id))
    @task.creator = current_user
    if @task.save
      render json: @task, status: :created
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def update
    if current_user.id == @task.assigned_user_id && current_user.memberships.find_by(team_id: @task.team_id)&.role == 'member'
      if (task_params.keys - ['status']).any?
        return render json: { error: 'You can only update status of your task' }, status: :forbidden
      end
    else
      authorize! :manage, @task
    end

    if @task.update(task_params)
      render json: @task.as_json
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def assign
    authorize! :manage, @task

    new_user_id = params[:assigned_user_id]

    if new_user_id.to_i == current_user.id
      return render json: { error: 'You cannot assign a task to yourself' }, status: :unprocessable_entity
    end
    #debugger
    unless @task.team.users.exists?(id: new_user_id)
      return render json: { error: 'Assigned user must be a team member' }, status: :unprocessable_entity
    end

    @task.assigned_user_id = new_user_id

    if @task.save
      render json: { message: 'Task assigned successfully', task: @task.as_json }, status: :ok
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
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assigned_user_id)
  end
end
