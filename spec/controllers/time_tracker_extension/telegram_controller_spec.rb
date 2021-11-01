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
        let(:current_user) { create(:user) }
        subject { -> { dispatch_command :check_token, 'token' } }
        it { should respond_with_message I18n.t("telegram.token_is_invalid") }

        it "should set the right context" do
          expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:save_context).with(:check_token!)
          dispatch_command(:check_token, 'token', { from: { id: 3 } } )
        end
      end

    end

    describe '#approve_period_callback_query', :callback_query do
      let!(:current_user) { create(:user, telegram_id: 1) }
      let!(:period) { create(:time_locking_period, user: current_user, approved: false) }

      def execute_callback_query(period)
        dispatch(callback_query: { "id" => "825638170257681899", from: { id: 1 }, message: { chat: { id: "1" }, message_id: "1" }, data: "approve_period:#{period.id}"})
      end

      it "should create approve form" do
        allow(User).to receive(:find_by) { current_user }
        allow(current_user).to receive_message_chain(:time_locking_periods, :find_by) { period }
        expect(TimeTrackerExtension::TimeLockingPeriods::UpdateForm).to receive(:new).with({ approved: true }, period) { double(save: true) }
        execute_callback_query(period)
      end

      it "should return query message - done" do
        message = I18n.t('telegram.done')
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:answer_callback_query).with(message)
        execute_callback_query(period)
      end

      it "should change message about approving timereport" do
        message = I18n.t('telegram.period_was_succesfully_approved', workspace: period.workspace.name, from: period.beginning_of_period, to: period.end_of_period)
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:edit_message).with("text", { text: message })
        execute_callback_query(period)
      end

      it "should return error about inconsistent data" do
        allow(User).to receive(:find_by) { current_user }
        allow(current_user).to receive_message_chain(:time_locking_periods, :find_by) { period }
        form = TimeTrackerExtension::TimeLockingPeriods::UpdateForm.new({ approved: true }, period)
        allow(TimeTrackerExtension::TimeLockingPeriods::UpdateForm).to receive(:new) { form }
        form.errors.add(:base, "error message")
        form.dates_of_invalid_time_records = ["2021-10-29", "2021-10-30"]
        allow(form).to receive(:save) { false }
        links = "[2021-10-29](https://#{ENV['FRONTEND_HOST']}/tasks?date=2021-10-29), [2021-10-30](https://#{ENV['FRONTEND_HOST']}/tasks?date=2021-10-30)"
        message = I18n.t('telegram.period_has_inconsistent_data', dates: links)
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:edit_message).with("text", { text: message, parse_mode: :Markdown })
        execute_callback_query(period)
      end
    end

    describe '#today_tasks!' do
      let!(:current_user) { create(:user, telegram_id: 1) }

      it "should return error in case of accessing by authorized user" do
        error_message = I18n.t("telegram.please_link_your_account_first")
        expect { dispatch_command(:today_tasks, { from: { id: 2 } }) }.to respond_with_message(error_message)
      end

      it "should return generated message" do
        allow(TimeTrackerExtension::TelegramMessageGenerators::TodayTasks).to receive(:new) { double(perform: "today_tasks_message") }
        expect { dispatch_command(:today_tasks, { from: { id: 1 } }) }.to respond_with_message("today_tasks_message")
      end
    end

    describe '#active_task!' do
      let!(:current_user) { create(:user, telegram_id: 1) }

      it "should return generated message" do
        message = { text: 'active_task_message' }
        allow(TimeTrackerExtension::TelegramMessageGenerators::ActiveTask).to receive(:new) { double(perform: message) }
        expect { dispatch_command(:active_task, { from: { id: 1 } }) }.to send_telegram_message(bot, "active_task_message")
      end
    end

    describe 'stop_active_task' do
      let!(:current_user) { create(:user, telegram_id: 1) }
      let!(:time_record) { create(:time_record, user: current_user, time_start: Time.now) }

      def execute_callback_query(time_record)
        dispatch(callback_query: { "id" => "825638170257681899", from: { id: 1 }, message: { chat: { id: "1" }, message_id: "1" }, data: "stop_active_task:#{time_record.id}"})
      end

      it "should stop active time period" do
        allow(User).to receive(:find_by) { current_user }
        allow(current_user).to receive_message_chain(:time_records, :find) { time_record }
        execute_callback_query(time_record)
        expect(time_record.reload.time_start).to be_nil
      end

      it "should change message about active task" do
        message = I18n.t('telegram.task_was_stopped', description: time_record.description, time: time_record.calculated_spent_time, project: time_record.project.name)
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:edit_message).with("text", { text: message })
        execute_callback_query(time_record)
      end

      it "should return query message - done" do
        message = I18n.t('telegram.done')
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:answer_callback_query).with(message)
        execute_callback_query(time_record)
      end
    end

    describe '#total_time!' do
      let!(:current_user) { create(:user, telegram_id: 1) }

      it "should return generated message" do
        week_button = double
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).with(text: I18n.t("telegram.total_time.week"), callback_data: "total_time:week") { week_button }
        month_button = double
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new).with(text: I18n.t("telegram.total_time.month"), callback_data: "total_time:month") { month_button }


        message = I18n.t("telegram.total_time.select_period")
        expect { dispatch_command(:total_time, { from: { id: 1 } }) }.to send_telegram_message(bot, message, { reply_markup: { inline_keyboard: [[ week_button, month_button]] } })
      end
    end

    describe "total_time_callback_query" do
      let!(:current_user) { create(:user, telegram_id: 1) }

      def execute_callback_query
        dispatch(callback_query: { "id" => "825638170257681899", from: { id: 1 }, message: { chat: { id: "1" }, message_id: "1" }, data: "total_time:week"})
      end

      it "should call message generator" do
        allow(User).to receive(:find_by) { current_user }
        expect(TimeTrackerExtension::TelegramMessageGenerators::TotalTime).to receive(:new).with(current_user, 'week') { double(perform: "message") }
        execute_callback_query
      end

      it "should generate and return message" do
        allow(TimeTrackerExtension::TelegramMessageGenerators::TotalTime).to receive(:new) { double(perform: 'message') }
        expect_any_instance_of(TimeTrackerExtension::TelegramController).to receive(:edit_message).with("text", { text: 'message' })
        execute_callback_query
      end
    end

    describe '#unapproved_reports!' do
      let!(:current_user) { create(:user, telegram_id: 1) }

      it "should return message for staff users" do
        allow(User).to receive(:find_by) { current_user }
        allow(current_user).to receive(:staff?) { true }

        expect { dispatch_command(:unapproved_reports, { from: { id: 1 } }) }.to respond_with_message(I18n.t("telegram.forbidden"))
      end

      it "should return generated message" do
        allow(User).to receive(:find_by) { current_user }
        allow(current_user).to receive(:staff?) { false }

        allow(TimeTrackerExtension::TelegramMessageGenerators::UnapprovedReports).to receive(:new) { double(perform: 'message') }
        expect { dispatch_command(:unapproved_reports, { from: { id: 1 } }) }.to respond_with_message('message')
      end
    end
  end

end
