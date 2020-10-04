module TimeTrackerExtension
  module TimeLockingPeriods
    class ApproveForm < TimeTrackerExtension::TimeLockingPeriods::BaseForm
      validate :does_not_contain_running_tasks

      def initialize(period)
        @period = period
        @workspace = period.workspace
        @user = period.user
        super(period.attributes)
      end

      def save
        return true if approved
        if valid?
          approve_record
          launch_job_about_sending_reports_to_admins
          true
        else
          false
        end
      end

      private

      def approve_record
        period.update(approved: true)
      end

      def launch_job_about_sending_reports_to_admins
        TimeTrackerExtension::SendPeriodReportsJob.perform_later(period)
      end

      def does_not_contain_running_tasks
        if workspace.time_records.
          where("time_records.assigned_date BETWEEN ? AND ?", beginning_of_period, end_of_period).
          where("time_records.time_start IS NOT NULL").
          where("time_records.user_id = ?", user.id).
          any?
          errors.add(:base, I18n.t("time_locking_periods.has_active_task"))
        end
      end
    end
  end
end
