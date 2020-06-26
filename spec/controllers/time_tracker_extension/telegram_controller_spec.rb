require 'rails_helper'
require './spec/support/telegram_integration'

module TimeTrackerExtension

  RSpec.describe TelegramController, type: :request, telegram_bot: :rails do

    describe '#start!' do
      subject { -> { dispatch_command :start } }
      it { should respond_with_message I18n.t("telegram.please_set_your_token") }
    end

    describe '#check_token!' do

      context "in case of telegram account was already assigned to another user " do
        let!(:current_user) { create(:user, telegram_id: 1) }
        let!(:another_user) { create(:user, telegram_id: 2) }
        subject { -> { dispatch_command(:check_token, current_user.telegram_token, { from: { id: 2 } }) } }
        it { should respond_with_message I18n.t("telegram.this_account_was_linked") }
      end

      context "in case of telegram account was already assigned to current user " do
        let!(:current_user) { create(:user, telegram_id: 1) }
        subject { -> { dispatch_command(:check_token, current_user.telegram_token, { from: { id: 1 } } ) } }
        it { should respond_with_message I18n.t("telegram.telegram_was_assigned_to_account") }
      end

      context "in case of telegram account wasn't assigned to anyone" do
        let(:current_user) { create(:user, telegram_id: nil) }
        it "should return message about linking accounts" do
          expect { dispatch_command(:check_token, current_user.telegram_token, { from: { id: 3 } } ) }.
            to make_telegram_request(bot, :sendMessage).with(hash_including(text: I18n.t("telegram.telegram_was_assigned_to_account")))
        end

        it "should set telegram id to the user's account" do
          dispatch_command(:check_token, current_user.telegram_token, { from: { id: 3 } } )
          expect(current_user.reload.telegram_id).to eq(3)
        end
      end

      context "for invalid token" do
        subject { -> { dispatch_command :check_token, 'token' } }
        it { should respond_with_message I18n.t("telegram.token_is_invalid") }
      end

    end

    describe '#approve_period_callback_query', :callback_query do
      let!(:current_user) { create(:user, telegram_id: 1) }
      let!(:period) { create(:time_locking_period, user: current_user, approved: false) }

      def execute_callback_query(period)
        dispatch(callback_query: { "id" => "825638170257681899", from: { id: 1 }, message: { chat: { id: "1" }, message_id: "1" }, data: "approve_period:#{period.id}"})
      end

      it "should approved period" do
        execute_callback_query(period)
        expect(period.reload.approved).to be_truthy
      end

      it "should return query message - done" do
        message = I18n.t('telegram.done')
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:answer_callback_query).with(message)
        execute_callback_query(period)
      end

      it "should change message about approving timereport" do
        message = I18n.t('telegram.period_was_succesfully_approved', from: period.beginning_of_period, to: period.end_of_period)
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:edit_message).with("text", { text: message })
        execute_callback_query(period)
      end
    end
  end

end
