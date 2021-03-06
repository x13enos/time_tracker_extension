module TimeTrackerExtension
  class TimeLockingPeriodsChecker

    class << self

      def execute
        periods = select_periods
        notify_users_about_timereports(periods)
      end

      private

      def select_periods
        TimeTrackerExtension::TimeLockingPeriod
          .includes(:user)
          .where("time_tracker_extension_time_locking_periods.end_of_period = ?", Date.today - 1.days)
      end

      def notify_users_about_timereports(periods)
        periods.each do |period|
          ::UserNotifier.new(
            user: period.user,
            notification_type: :approve_period,
            additional_data: { period: period },
            workspace_id: period.workspace_id
          ).perform
        end
      end

    end
  end
end
