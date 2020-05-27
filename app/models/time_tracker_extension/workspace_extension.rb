module TimeTrackerExtension
  module WorkspaceExtension
    def self.included(klass)
      klass.class_eval do
        has_many :time_locking_rules, class_name: '::TimeTrackerExtension::TimeLockingRule'
      end
    end
  end
end
