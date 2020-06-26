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
  end
end
