module TimeTrackerExtension
  class TimeLockingPeriod < ApplicationRecord
    belongs_to :workspace
    belongs_to :user

    validates :beginning_of_period, :end_of_period, presence: true
    validate :does_not_contain_running_tasks, if: :approved

    def unblock!
      related_periods = self.class.
                          where("beginning_of_period <= ? AND end_of_period >= ? AND workspace_id = ? AND user_id = ?",
                          beginning_of_period, end_of_period, workspace_id, user_id)
      related_periods.update_all(approved: false)
    end

    private

    def running_tasks
      workspace.time_records.
      where("time_records.assigned_date BETWEEN ? AND ?", beginning_of_period, end_of_period).
      where("time_records.time_start IS NOT NULL").
      where("time_records.user_id = ?", user.id)
    end

    def does_not_contain_running_tasks
      if running_tasks.any?
        errors.add(:base, I18n.t("time_locking_periods.has_active_task"))
      end
    end
  end
end
