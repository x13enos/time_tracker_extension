module TimeTrackerExtension
  class BlockedDaysSearcher
    def initialize(user, workspace_id, current_date)
      @user = user
      @workspace_id = workspace_id
      @current_date = current_date
    end

    def perform
      periods = get_approved_locking_periods
      return [] unless periods.any?
      find_blocked_days(periods)
    end

    private
    attr_reader :user, :workspace_id, :current_date

    def get_approved_locking_periods
      user.time_locking_periods.where(
        "workspace_id = ? AND approved = true AND (beginning_of_period >= ? OR end_of_period <= ?)",
        workspace_id, current_date.beginning_of_week, current_date.end_of_week
      )
    end

    def find_blocked_days(periods)
      current_week_days_range = (current_date.beginning_of_week..current_date.end_of_week).to_a
      periods.inject([]) do |blocked_days, period|
        period_days_range = (period.beginning_of_period..period.end_of_period).to_a
        blocked_days << (current_week_days_range & period_days_range)
        blocked_days
      end.flatten.uniq
    end
  end
end
