require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriod, type: :model do

    context "validations" do
      it { should validate_presence_of(:beginning_of_period) }
      it { should validate_presence_of(:end_of_period) }
    end

    context "associations" do
      it { should belong_to(:workspace)  }
      it { should belong_to(:user) }
    end

    describe "#unblock!" do
      let!(:today) { Date.today }
      let!(:workspace) { create(:workspace) }
      let!(:user) { create(:user, active_workspace_id: workspace.id, workspace_ids: [workspace.id]) }

      let!(:current_time_locking_period) do
        create(:time_locking_period,
               user: user,
               workspace: workspace,
               approved: true,
               beginning_of_period: today - 1.day,
               end_of_period: today + 1.day)
      end
      let!(:time_locking_period_1) do
        create(:time_locking_period,
               workspace: workspace,
               approved: true,
               beginning_of_period: today - 1.day,
               end_of_period: today + 1.day)
      end
      let!(:time_locking_period_2) do
        create(:time_locking_period,
               user: user,
               approved: true,
               beginning_of_period: today - 1.day,
               end_of_period: today + 1.day)
      end
      let!(:time_locking_period_3) do
        create(:time_locking_period,
               user: user,
               workspace: workspace,
               approved: true,
               beginning_of_period: today - 2.day,
               end_of_period: today - 1.day)
      end
      let!(:time_locking_period_4) do
        create(:time_locking_period,
               user: user,
               workspace: workspace,
               approved: true,
               beginning_of_period: today + 1.day,
               end_of_period: today + 2.day)
      end
      let!(:time_locking_period_5) do
        create(:time_locking_period,
               user: user,
               workspace: workspace,
               approved: true,
               beginning_of_period: today - 2.day,
               end_of_period: today + 2.day)
      end

      it "should unblock current and all related periods" do
        current_time_locking_period.unblock!
        expect(current_time_locking_period.reload.approved).to be_falsey
        expect(time_locking_period_5.reload.approved).to be_falsey

        expect(time_locking_period_1.reload.approved).to be_truthy
        expect(time_locking_period_2.reload.approved).to be_truthy
        expect(time_locking_period_3.reload.approved).to be_truthy
        expect(time_locking_period_4.reload.approved).to be_truthy
      end
    end
  end
end
