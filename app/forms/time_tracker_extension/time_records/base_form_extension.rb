module TimeTrackerExtension
  module TimeRecords

    module BaseFormExtension
      def self.included(klass)
        klass.class_eval do

          validate :cannot_execute_for_blocked_days

          private

          def cannot_execute_for_blocked_days
            blocked_days = self.user.time_locking_periods.where(
              "workspace_id = :workspace_id AND approved = true AND (beginning_of_period <= :assigned_date AND end_of_period >= :assigned_date)",
              {
                workspace_id: self.user.active_workspace_id,
                assigned_date: self.assigned_date
              }
            )
            return if blocked_days.empty?
            errors.add(:base, I18n.t("time_records.errors.cannot_execute_for_blocked_days"))
          end

        end
      end
    end

  end
end
