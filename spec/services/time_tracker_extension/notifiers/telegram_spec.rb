require "rails_helper"

module TimeTrackerExtension
  RSpec.describe Notifiers::Telegram do
    let(:user) { create(:user, telegram_id: 3124432) }

    describe "approve_period" do

      let(:telegram_response) do
        {
          "result" => {
            "message_id" => 145
          }
        }
      end

      it "should send message with 'approve' button to user" do
        allow(I18n).to receive(:t).and_call_original

        period = double(id: 22, beginning_of_period: "1/01/2020", end_of_period: "7/01/2020", workspace: double(name: "workspace's name"), update: true)
        allow(I18n).to receive(:t).with("telegram.please_approve_period", workspace: "workspace's name", from: period.beginning_of_period, to: period.end_of_period) { 'telegram message' }

        button = double
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).with(text: I18n.t("telegram.approve_period"), callback_data: "approve_period:#{period.id}") { button }

        expect(Telegram.bot).to receive(:send_message).with(chat_id: user.telegram_id, text: 'telegram message', reply_markup: { inline_keyboard: [[button]] }) { telegram_response }
        TimeTrackerExtension::Notifiers::Telegram.new(user, { period: period }).approve_period
      end

      it "should update period with the message telegram id" do
        period = create(:time_locking_period)
        allow(Telegram.bot).to receive(:send_message) { telegram_response }
        expect(period).to receive(:update).with(telegram_message_id: 145)
        TimeTrackerExtension::Notifiers::Telegram.new(user, { period: period }).approve_period
      end

    end

    describe "assign_user_to_project" do
      let!(:project) { create(:project) }

      it "should send message" do
        project.users << user
        allow(I18n).to receive(:t).with("telegram.you_were_assigned_to_project", project: project.name, workspace: project.workspace.name) { 'telegram message' }

        expect(Telegram.bot).to receive(:send_message).with(chat_id: user.telegram_id, reply_markup: {}, text: 'telegram message')
        TimeTrackerExtension::Notifiers::Telegram.new(user, { project: project }).assign_user_to_project
      end

    end

    describe "daily_report" do
      let!(:report_data) do
        {
          workspace_name: "random workspace",
          user: user,
          users_data: {
            "1": {
              name: "John",
              tasks_count: 1,
              total_time: 2.15
            }
          }
        }
      end

      it "should send message" do
        I18n.t("telegram.daily_report.body", user_name: user.name, workspace: report_data[:workspace_name])
        allow(I18n).to receive(:t).with("telegram.daily_report.body", user_name: user.name, workspace: "random workspace") { 'body/' }
        allow(I18n).to receive(:t).with("telegram.daily_report.user_data", index: 1, name: "John", count: 1, time: 2.15) { 'user_data/' }
        allow(I18n).to receive(:t).with("telegram.daily_report.footer") { 'footer' }

        expect(Telegram.bot).to receive(:send_message).with(chat_id: user.telegram_id, reply_markup: {}, text: 'body/user_data/footer')
        TimeTrackerExtension::Notifiers::Telegram.new(user, { report_data: report_data }).daily_report
      end

    end
  end
end
