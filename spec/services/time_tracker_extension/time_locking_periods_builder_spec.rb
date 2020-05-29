require "rails_helper"

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriodsBuilder do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user) }
    let!(:user2) { create(:user) }

    before do
      workspace.users << [user, user2]
    end

    it "should not create any periods if it isn't Monday or first day of month" do
      weekly_rule = create(:time_locking_rule, workspace: workspace, period: TimeTrackerExtension::TimeLockingRule.periods[:weekly])
      monthly_rule = create(:time_locking_rule, workspace: workspace, period: TimeTrackerExtension::TimeLockingRule.periods[:monthly])

      time = Date.today.beginning_of_week + 1.days
      time += 1.days if time.day === 1
      travel_to time
      TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
      expect(TimeTrackerExtension::TimeLockingPeriod.count).to eq(0)
      travel_back
    end

    it "should create periods for weeekly rules if today is Monday" do
      weekly_rule = create(:time_locking_rule, workspace: workspace, period: TimeTrackerExtension::TimeLockingRule.periods[:weekly])

      travel_to Date.today.beginning_of_week
      TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
      expect(TimeTrackerExtension::TimeLockingPeriod.count).to eq(2)
      travel_back
    end


    it "should create periods for monthly rules if today is first day of month" do
      monthly_rule = create(:time_locking_rule, workspace: workspace, period: TimeTrackerExtension::TimeLockingRule.periods[:monthly])

      travel_to Date.today.beginning_of_month
      TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
      expect(TimeTrackerExtension::TimeLockingPeriod.count).to eq(2)
      travel_back
    end

    context "check params" do
      let!(:weekly_rule) { create(:time_locking_rule, workspace: workspace, period: TimeTrackerExtension::TimeLockingRule.periods[:weekly]) }

      before do
        travel_to Date.today.beginning_of_week
        TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
        travel_back
      end

      it "should has right beginning of period" do
        expect(TimeTrackerExtension::TimeLockingPeriod.last.beginning_of_period).to eq(Date.today.beginning_of_week)
      end

      it "should has right end of period" do
        expect(TimeTrackerExtension::TimeLockingPeriod.last.end_of_period).to eq(Date.today.end_of_week)
      end

      it "should contain approved as false" do
        expect(TimeTrackerExtension::TimeLockingPeriod.last.approved).to be_falsey
      end

      it "should set the right workspace" do
        expect(TimeTrackerExtension::TimeLockingPeriod.last.workspace_id).to eq(workspace.id)
      end

      it "should set the right user" do
        expect(TimeTrackerExtension::TimeLockingPeriod.last.user_id).to eq(user2.id)
      end
    end
  end
end
