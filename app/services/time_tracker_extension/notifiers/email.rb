module TimeTrackerExtension
  module Notifiers::Email

    def approve_period
      TimeTrackerExtension::UserMailer.approve_time_locking_period(user, additional_data[:period]).deliver_now
    end

    def period_reports
      TimeTrackerExtension::UserMailer.period_reports(user, additional_data[:reports], additional_data[:period]).deliver_now
    end

  end
end
