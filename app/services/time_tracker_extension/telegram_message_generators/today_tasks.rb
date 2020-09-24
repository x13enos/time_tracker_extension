module TimeTrackerExtension
  module TelegramMessageGenerators
    class TodayTasks
      def initialize(user)
        @user = user
      end

      def perform
        time_records = select_time_records
        generate_message(time_records)
      end

      private
      attr_reader :user

      def select_time_records
        user.time_records.
             by_workspace(user.active_workspace_id).
             where(assigned_date: Date.today).
             order(created_at: :asc)
      end

      def generate_message(time_records)
        message = I18n.t("telegram.today_tasks.body", workspace: user.active_workspace.name)
        add_time_records_message(message, time_records.group_by(&:project_id))
        message << I18n.t('telegram.today_tasks.total_time', total_time: time_records.map(&:calculated_spent_time).sum)
        return message
      end

      def add_time_records_message(message, grouped_time_records)
        grouped_time_records.each do |project, time_records|
          message << (grouped_time_records.keys.one? ? "\n" : "\n#{time_records.first.project.name}:\n")
          time_records.each do |t|
            message << I18n.t('telegram.today_tasks.time_record_data', description: t.description, time: t.calculated_spent_time)
          end
        end
      end
    end
  end
end
