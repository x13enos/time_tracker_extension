module TimeTrackerExtension
  module UserExtension
    def self.included(klass)
      klass.class_eval do
        has_many :time_locking_periods,
          class_name: '::TimeTrackerExtension::TimeLockingPeriod', dependent: :destroy

        def unapproved_periods
          time_locking_periods
            .where("workspace_id = ? AND approved = false AND end_of_period < ?", active_workspace_id, Date.today)
        end

      end
    end
  end
end
