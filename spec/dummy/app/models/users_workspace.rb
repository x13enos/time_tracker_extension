class UsersWorkspace < ApplicationRecord
  enum role: { staff: 0, admin: 1, owner: 2 }

  before_create :set_notification_rules

  belongs_to :workspace
  belongs_to :user

  private

  def set_notification_rules
    self.notification_rules = ['email_assign_user_to_project']
  end
end
