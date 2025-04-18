class Task < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'
  belongs_to :assigned_user, class_name: 'User', optional: true
  
  enum status: { pending: 0, in_progress: 1, completed: 2 }
  enum priority: { low: 0, medium: 1, high: 2 }

  validates :title, presence: true
  validates :status, :priority, presence: true

  # after_update :send_notifications

  private
  
  #Notification
  def send_notifications
    if assigned_user_id_previously_changed?
      TaskMailer.task_assigned(self).deliver_later
    elsif saved_change_to_status? && completed?
      TaskMailer.task_completed(self).deliver_later
    end
  end
end