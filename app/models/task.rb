class Task < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :assigned_users, class_name: 'User'

  enum status: { pending: 0, in_progress: 1, completed: 2 }
  enum priority: { low: 0, medium: 1, high: 2 }

  validates :title, presence: true
  validates :status, :priority, presence: true
  validate :due_date_cannot_be_in_the_past

   after_save :send_notifications
    attr_accessor :previous_assigned_user_ids

  def assigned_user_details
    assigned_users.select(:id, :name)
  end


  private

  def send_notifications
    if previous_assigned_user_ids
      new_user_ids = assigned_user_ids - previous_assigned_user_ids

      User.where(id: new_user_ids).each do |user|
        TaskMailer.task_assigned(self, user).deliver_later
      end
    end

    if saved_change_to_status? && completed?
      TaskMailer.task_completed(self).deliver_later
    end
  end


  def due_date_cannot_be_in_the_past
    if due_date.present? && due_date < Date.today
      errors.add(:due_date, "can't be in the past")
    end
  end
end
