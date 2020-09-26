module TimeTrackerExtension
  module TelegramMessageGenerators
    class ActiveTask
      def initialize(user)
        @user = user
      end

      def perform
        if active_task
          { text: message_about_found_task, reply_markup: { inline_keyboard: [[stop_button]] } }
        else
          { text: message_about_not_found_task }
        end
      end

      private
      attr_reader :user

      def stop_button
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t("telegram.stop"), callback_data: "stop_active_task:#{active_task.id}")
      end

      def active_task
        @active_task ||= user.time_records.by_workspace(user.active_workspace_id).find_by("time_start IS NOT NULL")
      end

      def message_about_found_task
        I18n.t("telegram.active_task", description: active_task.description, time: active_task.calculated_spent_time, project: active_task.project.name)
      end

      def message_about_not_found_task
        I18n.t("telegram.active_task_is_not_found")
      end
    end
  end
end
