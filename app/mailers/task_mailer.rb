class TaskMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def task_assigned(task)
    @task = Task.includes(:assigned_user).find(task.id)
    return if @task.assigned_user.nil?

    mail(to: @task.assigned_user.email, subject: "New Task Assigned: #{@task.title}")
  end

  def task_completed(task)
    @task = task
    return if @task.creator.nil?
    mail(to: @task.creator.email, subject: "Task Completed: #{@task.title}")
  end
end
