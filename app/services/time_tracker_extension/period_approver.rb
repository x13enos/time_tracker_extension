module TimeTrackerExtension
  class PeriodApprover
    attr_reader :period

    def initialize(period)
      @period = period
    end

    def perform
      if period.update(approved: true)
        update_telegram_message
        TimeTrackerExtension::SendPeriodReportsJob.perform_later(period)
        true
      else
        false
      end
    end

    private

    def update_telegram_message
      return unless period.telegram_message_id

      text = I18n.t(
        'telegram.period_was_succesfully_approved',
        workspace: period.workspace.name,
        from: period.beginning_of_period,
        to: period.end_of_period
      )
      Telegram.bot.edit_message_text(chat_id: period.user.telegram_id, text: text, message_id: period.telegram_message_id)
    end

  end
end
