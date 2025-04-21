class TestMailerController < ApplicationController
  def send_test_email
    user = User.first # or find_by(email: 'your_email@gmail.com')
    task = Task.first # any sample task

    if user && task
      TaskMailer.task_assigned(task).deliver_later
      render json: { message: 'Test email enqueued 🎉' }, status: :ok
    else
      render json: { error: 'User or Task not found' }, status: :not_found
    end
  end
end
