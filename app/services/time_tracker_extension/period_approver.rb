module TimeTrackerExtension
  class PeriodApprover
    attr_reader :period

    def initialize(period)
      @period = period
    end

    def perform
      if period.update(approved: true)
        TimeTrackerExtension::SendPeriodReportsJob.perform_later(period)
        true
      else
        false
      end
    end

  end
end
