module TimeTrackerExtension
  class SendPeriodReportsJob < TimeTrackerExtension::ApplicationJob
    queue_as :default

    def perform(time_locking_period)
      TimeTrackerExtension::ReportsSender::Period.new(time_locking_period).perform
    end
  end
end
