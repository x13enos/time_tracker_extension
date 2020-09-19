module TimeTrackerExtension
  module ReportsSender
    class Period
      def initialize(period)
        @period = period
      end

      def perform
        return false if some_users_does_not_approve_period?
        generate_reports
        send_notifications
      end

      private
      attr_reader :period, :reports

      def some_users_does_not_approve_period?
        TimeTrackerExtension::TimeLockingPeriod.where(
          beginning_of_period: period.beginning_of_period,
          end_of_period: period.end_of_period,
          workspace_id: period.workspace.id,
          approved: false
        ).any?
      end

      def generate_reports
        @reports = users.inject({}) do |memo, user|
          time_records_data = time_records_data(user)
          report_generator = ReportGenerator.new(time_records_data, user)
          memo[user.name] = report_generator.file
          memo
        end
      end

      def send_notifications
        users.where("users_workspaces.role <> ?", UsersWorkspace.roles[:staff]).each do |user|
          ::UserNotifier.new(
            user: user,
            notification_type: :period_reports,
            additional_data: { reports: reports, period: period },
            workspace_id: period.workspace_id
          ).perform
        end
      end

      def time_records_data(user)
        TimeRecordsSelector.new({
          from_date: period.beginning_of_period,
          to_date: period.end_of_period,
          workspace_id: period.workspace.id
        }, user).perform
      end

      def users
        @users ||= period.workspace.users
      end
    end
  end
end
