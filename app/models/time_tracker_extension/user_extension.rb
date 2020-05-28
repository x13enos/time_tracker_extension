module TimeTrackerExtension
  module UserExtension
    def self.included(klass)
      klass.class_eval do
        has_many :time_locking_periods, class_name: '::TimeTrackerExtension::TimeLockingPeriod'
      end
    end
  end
end
