module TimeTrackerExtension
  class Notifiers::Telegram < ::Notifiers::Base

    def approve_period
      period = args[:period]
      button = Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t("telegram.approve_period"), callback_data: "approve_period:#{period.id}")
      send_message(
        I18n.t("telegram.please_approve_period", from: period.beginning_of_period, to: period.end_of_period),
        { inline_keyboard: [[button]] }
      )
    end

    def assign_user_to_project
      project = args[:project]
      send_message(
        I18n.t("telegram.you_were_assigned_to_project", project: project.name, workspace: project.workspace.name),
      )
    end

    private

    def send_message(text, markup = {})
      Telegram.bot.send_message(chat_id: user.telegram_id, text: text, reply_markup: markup)
    end

  end
end
