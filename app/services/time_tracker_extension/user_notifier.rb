module TimeTrackerExtension
  class UserNotifier
    def initialize(user, notification_type, args)
      @user = user
      @args = args
      @notification_type = notification_type
    end

    def perform
      I18n.with_locale(user.locale, &Proc.new { notifications })
    end

    private
    attr_reader :user, :notification_type, :args

    def notifications
      notify_by_email
      notify_by_telegram if user.telegram_id
    end

    def notify_by_email
      TimeTrackerExtension::Notifiers::Email.new(user, args).send(notification_type)
    end

    def notify_by_telegram
      TimeTrackerExtension::Notifiers::Telegram.new(user, args).send(notification_type)
    end
  end
end
