require "rails_helper"

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriodsChecker do
    let(:user) { create(:user) }
    let(:period) do
      create(:time_locking_period,
        user: user,
        beginning_of_period: (Date.today - 1.week).beginning_of_week,
        end_of_period: (Date.today - 1.week).end_of_week,
      )
    end

    def launch_service
      travel_to Date.today.beginning_of_week
      TimeTrackerExtension::TimeLockingPeriodsChecker.execute
      travel_back
    end

    describe ".execute" do
      it "should build notifier" do
        expect(::UserNotifier).to receive(:new).with({
          user: user,
          notification_type: :approve_period,
          additional_data: { period: period },
          workspace_id: period.workspace_id
        }) { double(perform: true)}
        launch_service
      end

      it "should launch notifier" do
        notifier = double
        allow(::UserNotifier).to receive(:new).with({
          user: user,
          notification_type: :approve_period,
          additional_data: { period: period },
          workspace_id: period.workspace_id
        }) { notifier }
        expect(notifier).to receive(:perform)
        launch_service
      end
    end
  end
end
