require "rails_helper"

module TimeTrackerExtension
  RSpec.describe PeriodApprover do
    let!(:period) { create(:time_locking_period) }

    describe ".initialize" do
      it "should assign period to the instance attribute" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        expect(approver.period).to eq(period)
      end
    end

    describe "#perform" do
      context "period was approved" do
        let(:approver) { TimeTrackerExtension::PeriodApprover.new(period) }

        before do
          allow(period).to receive(:update) { true }
        end

        it "should return true" do
          expect(approver.perform).to be_truthy
        end

        it "should call job for sending reports to admins" do
          expect(TimeTrackerExtension::SendPeriodReportsJob).to receive(:perform_later).with(period)
          approver.perform
        end

        it "should change telegram message text if period has that" do
          allow(approver.period).to receive(:telegram_message_id) { 133 }
          allow(approver.period.user).to receive(:telegram_id) { 122 }
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
          approver.perform
        end

        it "should clean up period's telegram_message_id after the changing message" do
          approver.period.update(telegram_message_id: 18283248)
          allow(Telegram.bot).to receive(:edit_message_text)
          approver.perform
          expect(approver.period.telegram_message_id).to be_nil
        end

        it "should not change telegram message text if period hasn't that" do
          allow(approver.period).to receive(:telegram_message_id) { nil }
          expect(Telegram.bot).to_not receive(:edit_message_text)
          approver.perform
        end
      end

      it "should return false if period was not approved" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        allow(period).to receive(:update).with(approved: true) { false }
        expect(approver.perform).to be_falsey
      end
    end

  end
end
