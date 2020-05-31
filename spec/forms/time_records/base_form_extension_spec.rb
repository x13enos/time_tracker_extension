require 'rails_helper'

RSpec.describe TimeRecords::BaseForm, type: :model do

  context 'validations' do
    describe "#assigned_date_should_not_be_blocked" do
      let!(:user) { create(:user) }
      let!(:project) { create(:project, workspace: user.active_workspace) }
      let!(:time_record_form) {
        TimeRecords::BaseForm.new(
          user: user,
          project_id: project.id,
          spent_time: 0.5,
          description: "test",
          assigned_date: Date.today
        )
      }

      it "should add error if assigned date was included to any blocking periods" do
        period = create(:time_locking_period,
          user: user,
          approved: true,
          workspace: user.active_workspace,
          beginning_of_period: Date.today - 3.days,
          end_of_period: Date.today + 3.days)

        time_record_form.valid?
        expect(time_record_form.errors[:base]).to eq([I18n.t("time_records.errors.cannot_execute_for_blocked_days")])
      end

      it "should not add error if assigned date was not included to any blocking periods" do
        period = create(:time_locking_period,
          user: user,
          approved: true,
          workspace: user.active_workspace,
          beginning_of_period: Date.today - 3.days,
          end_of_period: Date.today - 2.days)

        time_record_form.valid?
        expect(time_record_form.errors[:base]).to be_empty
      end

      it "should not add error if assigned date was not included to any approved blocking periods" do
        period = create(:time_locking_period,
          user: user,
          approved: false,
          workspace: user.active_workspace,
          beginning_of_period: Date.today - 3.days,
          end_of_period: Date.today + 2.days)

        time_record_form.valid?
        expect(time_record_form.errors[:base]).to be_empty
      end

    end
  end

end
