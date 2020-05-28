module TimeTrackerExtension
  class TimeLockingPeriodsBuilder
    TYPE_OF_PERIOD = {
      weekly: 'week',
      monthly: 'month'
    }
    
    class << self
      def execute
        select_rules
        build_time_locking_periods
      end

      private
      def select_rules
        @rules = TimeTrackerExtension::TimeLockingRule
          .includes(:users)
          .where("time_tracker_extension_time_locking_rules.period IN (?)", needed_periods)
      end

      def needed_periods
        [].tap do |periods|
          periods << TimeTrackerExtension::TimeLockingRule.periods[:weekly] if Date.today.monday?
          periods << TimeTrackerExtension::TimeLockingRule.periods[:monthly]  if Date.today.day == 1
        end
      end

      def build_time_locking_periods
        @rules.each do |rule|
          rule.users.each { |user| create_period(user, rule) }
        end
      end

      def create_period(user, rule)
        # TODO send error of creating to the rollbar
        user.time_locking_periods.create(
          approved: false,
          workspace_id: rule.workspace_id,
          beginning_of_period: Time.now.send("beginning_of_#{TYPE_OF_PERIOD[rule.period.to_sym]}"),
          end_of_period: Time.now.send("end_of_#{TYPE_OF_PERIOD[rule.period.to_sym]}"),
        )
      end
    end
  end
end
