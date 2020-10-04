require 'rails_helper'

RSpec.describe TimeTrackerExtension::TimeLockingPeriods::ApproveForm, type: :model do
  let(:user) { create(:user) }
  let(:time_locking_period) { create(:time_locking_period, user: user, workspace: user.active_workspace, approved: false) }

  context 'validations' do
    let!(:form) { TimeTrackerExtension::TimeLockingPeriods::ApproveForm.new(time_locking_period) }

    subject { form }

    describe 'does_not_contain_running_tasks' do
      it "should add error if active time_record was found in current period" do
        travel_to Time.zone.local(2019, 10, 29, 1, 0, 0)
        form.beginning_of_period = Date.today.beginning_of_week
        form.end_of_period = Date.today.end_of_week
        create(:time_record, user: form.user, workspace: form.workspace, time_start: Time.now, assigned_date: Date.today)
        form.valid?
        expect(form.errors[:base]).to include(I18n.t("time_locking_periods.has_active_task"))
        travel_back
      end

      it "shouldn't raise error if active time_record was not found in current period" do
        travel_to Time.zone.local(2019, 10, 29, 1, 0, 0)
        form.beginning_of_period = Date.today.beginning_of_week
        form.end_of_period = Date.today.end_of_week
        form.valid?
        expect(form.errors[:base]).to_not include(I18n.t("time_locking_periods.has_active_task"))
        travel_back
      end
    end
  end

  describe "save" do
    let!(:form) { TimeTrackerExtension::TimeLockingPeriods::ApproveForm.new(time_locking_period) }

    context "when form is valid" do
      before do
        allow(form).to receive(:valid?) { true }
      end

      it "should approve period" do
        expect{ form.save }.to change{ time_locking_period.approved }.from(false).to(true)
      end

      it "should create job for sening reports for admins" do
        expect(TimeTrackerExtension::SendPeriodReportsJob).to receive(:perform_later).with(form.period)
        form.save
      end
    end

    context "when form is invalid" do
      it "should raise error" do
        allow(form).to receive(:valid?) { false }
        expect(form.save).to be_falsey
      end
    end

  end

end
