module TimeTrackerExtension
  module Notifiers::Email

    def approve_period
      TimeTrackerExtension::UserMailer.approve_time_locking_period(user, args[:period]).deliver_now
    end

  end
end
