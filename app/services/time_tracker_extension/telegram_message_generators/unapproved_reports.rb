module TimeTrackerExtension
  module TelegramMessageGenerators
    class UnapprovedReports
      def initialize(user)
        @user = user
      end

      def perform
        reports = select_grouped_time_reports
        if reports.empty?
          I18n.t("telegram.unapproved_periods.no_reports")
        else
          message(reports)
        end
      end

      private
      attr_reader :user

      def select_grouped_time_reports
        sql = "SELECT CONCAT(p.beginning_of_period, ' | ', p.end_of_period) AS period_range, u.name "\
              "FROM time_tracker_extension_time_locking_periods as p "\
              "LEFT JOIN users as u "\
              "ON u.id = p.user_id "\
              "WHERE p.workspace_id = #{user.active_workspace_id} AND p.approved = false AND p.end_of_period < '#{Date.today}'"

        records_array = TimeTrackerExtension::TimeLockingRule.find_by_sql(sql)
        records_array.group_by(&:period_range)
      end

      def message(reports)
        message = I18n.t("telegram.unapproved_reports.body", workspace: user.active_workspace.name)
        reports.each do |period, users|
          message << "#{I18n.t('telegram.unapproved_reports.period_range', period: period)}"
          users.each { |user| message << I18n.t('telegram.unapproved_reports.user_name', name: user.name) }
        end

        return message
      end
    end
  end
end
