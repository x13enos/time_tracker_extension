module TimeTrackerExtension
  class Notifiers::Telegram < ::Notifiers::Base

    def approve_period
      period = additional_data[:period]
      button = Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t("telegram.approve_period"), callback_data: "approve_period:#{period.id}")
      send_message(
        I18n.t("telegram.please_approve_period", workspace: period.workspace.name, from: period.beginning_of_period, to: period.end_of_period),
        { inline_keyboard: [[button]] }
      )
    end

    def assign_user_to_project
      project = additional_data[:project]
      send_message(
        I18n.t("telegram.you_were_assigned_to_project", project: project.name, workspace: project.workspace.name),
      )
    end

    def daily_report
      report_data = additional_data[:report_data]
      message = I18n.t("telegram.daily_report.body", user_name: user.name, workspace: report_data[:workspace_name])
      report_data[:users_data].each_with_index do |(id, u), index|
        message << I18n.t('telegram.daily_report.user_data', index: index+1, name: u[:name], count: u[:tasks_count], time: u[:total_time])
      end
      message << I18n.t("telegram.daily_report.footer")
      send_message(message)
    end

    private

    def send_message(text, markup = {})
      Telegram.bot.send_message(chat_id: user.telegram_id, text: text, reply_markup: markup)
    end

  end
end
