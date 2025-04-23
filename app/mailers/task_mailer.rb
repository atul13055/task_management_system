class TaskMailer < ApplicationMailer
  default from: 'no-reply@yourapp.com'

  def task_assigned(task, user)
    # debugger
    @task = task
    @user = user

    return if @user.nil? || @user.email.blank?

    mail(to: @user.email, subject: "New Task Assigned: #{@task.title}")
  end

  def task_completed(task)
    # debugger
    @task = task
    return if @task.creator.nil?

    mail(to: @task.creator.email, subject: "Task Completed: #{@task.title}")
  end

  def task_unassigned(task, user)
    # debugger
    @task = task
    @user = user

    mail(to: @user.email, subject: "You have been removed from task: #{@task.title}")
  end
end
