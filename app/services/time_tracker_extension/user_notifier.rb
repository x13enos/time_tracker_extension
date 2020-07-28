module TimeTrackerExtension
  module UserNotifier

    private

    def notifications
      notify_by_email
      notify_by_telegram
    end

    def notify_by_telegram
      return unless user.telegram_id
      send_notification(TimeTrackerExtension::Notifiers::Telegram)
    end
  end
end
