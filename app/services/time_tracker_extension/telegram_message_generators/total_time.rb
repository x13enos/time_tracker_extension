module TimeTrackerExtension
  module TelegramMessageGenerators
    class TotalTime
      def initialize(user, period)
        @user = user
        @period = period
      end

      def perform
        time_records = select_time_records
        return message(time_records)
      end

      private
      attr_reader :user, :period

      def select_time_records
        user.time_records.
          by_workspace(user.active_workspace_id).
          where("assigned_date BETWEEN ? and ?", Date.today.send("beginning_of_#{period}"), Date.today.send("end_of_#{period}"))

      end

      def message(time_records)
        total_time = time_records.map(&:calculated_spent_time).sum
        locale_period = I18n.t("telegram.total_time.response_#{period}")
        I18n.t("telegram.total_time.time_and_number", number: time_records.size, time: total_time, period: locale_period)
      end
    end
  end
end
