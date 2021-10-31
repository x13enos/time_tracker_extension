require "rails_helper"

RSpec.describe TimeTrackerExtension::TimeLockingPeriods::UpdateForm do

  def build_form(*args)
    TimeTrackerExtension::TimeLockingPeriods::UpdateForm.new(*args)
  end

  let(:period) { create(:time_locking_period, approved: false, beginning_of_period: Date.today - 1.week, end_of_period: Date.today) }

  describe 'validations' do
    
    describe 'does_not_contain_running_tasks?' do
      
      it 'should add error in case of having running tasks for passed period' do
        create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 2.days, time_start: Time.now - 2.days)
        form = build_form({ approved: true }, period)
        form.valid?
        expect(form.errors[:base]).to include(I18n.t("time_locking_periods.has_active_task"))
      end

      it 'should not add error in case of absence running tasks for passed period' do
        create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today + 2.days, time_start: Time.now + 2.days)
        form = build_form({ approved: true }, period)
        form.valid?
        expect(form.errors[:base]).to_not include(I18n.t("time_locking_periods.has_active_task"))
      end

    end

    describe 'has_consistent_data?' do
      
      it 'should add error in case of having inconsisent data' do
        time_record_1 = create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 2.days, description: nil)
        time_record_2 = create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 2.days, description: nil)
        time_record_3 = create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 3.days, project_id: nil)
        form = build_form({ approved: true }, period)
        form.valid?
        dates = [time_record_1.assigned_date, time_record_3.assigned_date].join(", ")
        expect(form.errors[:base]).to include(I18n.t("time_locking_periods.has_inconsistent_data"))
      end

      it 'should add dates to the form\'s variable' do
        usual_data = { workspace: period.workspace, user: period.user }
        time_record_1 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 2.days, description: nil }))
        time_record_2 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 2.days, description: nil }))
        time_record_3 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 3.days, project_id: nil }))
        time_record_4 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 4.days, description: '' }))
        time_record_5 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 5.days, spent_time: 0.0 }))
        time_record_6 = create(:time_record, usual_data.merge({ assigned_date: Date.today - 8.days, spent_time: 0.0 }))
        form = build_form({ approved: true }, period)
        form.valid?
        dates = [time_record_1.assigned_date, time_record_3.assigned_date, time_record_4.assigned_date, time_record_5.assigned_date]
        expect(form.dates_of_invalid_time_records).to eq(dates)
      end

      it 'should not add error in case of having only consisent data' do
        create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today + 2.days, description: nil)
        create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 2.days)
        create(:time_record, workspace: period.workspace, user: period.user, assigned_date: Date.today - 3.days)
        form = build_form({ approved: true }, period)
        form.valid?
        expect(form.errors[:base]).to be_empty
      end
    end

  end

  describe ".initialize" do

    it "should add period to the form" do
      form = build_form({}, period)
      expect(form.period).to eq(period)
    end

    it "should pass attributes to the form" do
      form = build_form({ approved: true }, period)
      expect(form.approved).to be_truthy
    end
  end

  describe '#persist!' do
    let(:form) { build_form({ approved: true }, period) }

    it 'should update real period with passed data' do
      form.persist!
      expect(period.reload.approved).to be_truthy
    end

    it "should change telegram message text if period has that" do
      allow(period).to receive(:telegram_message_id) { 133 }
      allow(period.user).to receive(:telegram_id) { 122 }
      text = "new message"
      allow(I18n).to receive(:t).with(
        'telegram.period_was_succesfully_approved',
        workspace: period.workspace.name,
        from: period.beginning_of_period,
        to: period.end_of_period
      ) { text }
      expect(Telegram.bot).to receive(:edit_message_text).with(
        chat_id: 122,
        text: text,
        message_id: 133
      )
      form.persist!
    end

    it "should call job for sending reports to admins" do
      expect(TimeTrackerExtension::SendPeriodReportsJob).to receive(:perform_later).with(period)
      form.persist!
    end

    it "should clean up period's telegram_message_id after the changing message" do
      period.update(telegram_message_id: 18283248)
      allow(Telegram.bot).to receive(:edit_message_text)
      form.persist!
      expect(period.reload.telegram_message_id).to be_nil
    end

    it "should not change telegram message text if period hasn't that" do
      allow(period).to receive(:telegram_message_id) { nil }
      expect(Telegram.bot).to_not receive(:edit_message_text)
      form.persist!
    end
  end
end
