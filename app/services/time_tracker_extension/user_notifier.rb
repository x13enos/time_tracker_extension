module TimeTrackerExtension
  module UserNotifier

    private

    def notifications
      with_error_handling { notify_by_email }
      with_error_handling { notify_by_telegram }
    end

    def notify_by_telegram
      return unless user.telegram_id
      return unless notification_found_in_settings?('telegram')
      TimeTrackerExtension::Notifiers::Telegram.new(user, additional_data).send(notification_type)
    end

  end
end
