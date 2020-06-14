module TimeTrackerExtension
  module WorkspaceExtension
    def self.included(klass)
      klass.class_eval do
        has_many :time_locking_rules, class_name: '::TimeTrackerExtension::TimeLockingRule'
        has_many :time_locking_periods, class_name: '::TimeTrackerExtension::TimeLockingPeriod'
      end
    end
  end
end