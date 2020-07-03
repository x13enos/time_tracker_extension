module TimeTrackerExtension
  module UserNotifier

    private

    def notifications
      notify_by_email
      notify_by_telegram if user.telegram_id
    end

    def notify_by_telegram
      TimeTrackerExtension::Notifiers::Telegram.new(user, args).send(notification_type)
    end
  end
end
