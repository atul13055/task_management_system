class Task < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'
  belongs_to :assigned_user, class_name: 'User', optional: true
  
  enum status: { pending: 0, in_progress: 1, completed: 2 }
  enum priority: { low: 0, medium: 1, high: 2 }
end
