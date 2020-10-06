require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriod, type: :model do

    context "validations" do
      it { should validate_presence_of(:beginning_of_period) }
      it { should validate_presence_of(:end_of_period) }

      describe "does_not_contain_running_tasks" do
        let!(:today) { Date.today }
        let!(:workspace) { create(:workspace) }
        let!(:project) { create(:project, workspace: workspace) }
        let!(:user) { create(:user, active_workspace_id: workspace.id) }

        let!(:time_locking_period) do
          create(:time_locking_period,
                 user: user,
                 workspace: workspace,
                 approved: false,
                 beginning_of_period: today - 5.days,
                 end_of_period: today + 5.days)
        end

        it "should add error if user has active task in period of updated time_locking_period" do
          create(:time_record, user: user, project: project, time_start: Time.now)
          time_locking_period.update(approved: true)
          expect(time_locking_period.errors[:base]).to include(I18n.t("time_locking_periods.has_active_task"))
        end

        it "should not add error if user has active task in period of updated time_locking_period for another workspace" do
          create(:time_record, user: user, time_start: Time.now)
          time_locking_period.update(approved: true)
          expect(time_locking_period.errors[:base]).to be_empty
        end

        it "should not add error if user has active task in another period than in updated time_locking_period" do
          create(:time_record, user: user, time_start: Time.now - 10.days)
          time_locking_period.update(approved: true)
          expect(time_locking_period.errors[:base]).to be_empty
        end

        it "should not add error if active task in period of updated time_locking_period was created for another user" do
          create(:time_record, project: project, time_start: Time.now)
          time_locking_period.update(approved: true)
          expect(time_locking_period.errors[:base]).to be_empty
        end

        it "should skip validation if approved attribute is false" do
          create(:time_record, user: user, project: project, time_start: Time.now)
          time_locking_period.update(beginning_of_period: Date.today - 6.days)
          expect(time_locking_period.errors[:base]).to be_empty
        end
      end
    end

    context "associations" do
      it { should belong_to(:workspace)  }
      it { should belong_to(:user) }
    end

    describe "#unblock!" do
      let!(:today) { Date.today }
      let!(:workspace) { create(:workspace) }
      let!(:user) { create(:user, active_workspace_id: workspace.id) }

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
