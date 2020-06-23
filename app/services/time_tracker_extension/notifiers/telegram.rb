module TimeTrackerExtension
  class Notifiers::Telegram < TimeTrackerExtension::Notifiers::Base

    def approve_period
      period = args[:period]
      button = Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t("telegram.approve_period"), callback_data: "approve_period:#{period.id}")
      send_message(
        I18n.t("telegram.please_approve_period", from: period.beginning_of_period, to: period.end_of_period),
        { inline_keyboard: [[button]] }
      )
    end

    private

    def send_message(text, markup = {})
      Telegram.bot.send_message(chat_id: user.telegram_id, text: text, reply_markup: markup)
    end

  end
end
