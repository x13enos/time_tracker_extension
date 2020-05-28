require "rails_helper"

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriodsChecker do
    let!(:user) { create(:user) }

    it "should notify user about approving time records if period was finished" do
      period = create(:time_locking_period,
        user: user,
        beginning_of_period: (Date.today - 1.week).beginning_of_week,
        end_of_period: (Date.today - 1.week).end_of_week,
      )

      travel_to Date.today.beginning_of_week
      expect(TimeTrackerExtension::UserMailer).to receive(:approve_time_locking_period).with(period) { double(deliver_now: true)}
      TimeTrackerExtension::TimeLockingPeriodsChecker.execute
      travel_back
    end
  end
end
