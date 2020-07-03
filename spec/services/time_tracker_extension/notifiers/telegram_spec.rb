require "rails_helper"

module TimeTrackerExtension
  RSpec.describe Notifiers::Telegram do
    let(:user) { create(:user, telegram_id: 3124432) }

    describe "approve_period" do

      it "should send message with 'approve' button to user" do
        allow(I18n).to receive(:t).and_call_original

        period = double(id: 22, beginning_of_period: "1/01/2020", end_of_period: "7/01/2020")
        allow(I18n).to receive(:t).with("telegram.please_approve_period", from: period.beginning_of_period, to: period.end_of_period) { 'telegram message' }

        button = double
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).with(text: I18n.t("telegram.approve_period"), callback_data: "approve_period:#{period.id}") { button }

        expect(Telegram.bot).to receive(:send_message).with(chat_id: user.telegram_id, text: 'telegram message', reply_markup: { inline_keyboard: [[button]] })
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
  end
end
