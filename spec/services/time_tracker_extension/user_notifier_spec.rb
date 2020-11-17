require "rails_helper"

class DummyUserNotifier
  include TimeTrackerExtension::UserNotifier

  def initialize(notification_data)
    @user = notification_data[:user]
    @additional_data = notification_data[:additional_data]
    @notification_type = notification_data[:notification_type]
    @workspace_id = notification_data[:workspace_id]
  end

  private
  attr_reader :user, :notification_type, :additional_data, :workspace_id

  def notify_by_email
  end

  def with_error_handling
    yield
  end
end

module TimeTrackerExtension
  RSpec.describe UserNotifier do
    let(:user) { create(:user) }

    describe "private method - notifications" do
      let!(:notifier) do
        DummyUserNotifier.new({
          user: user,
          additional_data: {},
          notification_type: :approve_period
        })
      end

      it "should call method for sending email" do
        allow(notifier).to receive(:notify_by_email) { 'email success' }
        expect(notifier).to receive(:with_error_handling) do |&block|
          expect(block.call).to eq('email success')
        end
        expect(notifier).to receive(:with_error_handling).and_call_original

        notifier.send(:notifications)
      end

      it "should call method for sending telegram message" do
        allow(notifier).to receive(:notify_by_telegram) { 'telegram success' }
        expect(notifier).to receive(:with_error_handling).and_call_original

        expect(notifier).to receive(:with_error_handling) do |&block|
          expect(block.call).to eq('telegram success')
        end

        notifier.send(:notifications)
      end
    end

    describe "private method - notify_by_telegram" do
      let!(:notifier) do
        DummyUserNotifier.new({
          user: user,
          additional_data: {},
          notification_type: :approve_period
        })
      end

      it "should not call telegram notifier in case of absense the telegram id for user" do
        expect(TimeTrackerExtension::Notifiers::Telegram).to_not receive(:new)
        notifier.send(:notify_by_telegram)
      end

      it "should not call telegram notifier if user have been disabled this notification in settings" do
        allow(user).to receive(:telegram_id) { 1 }
        allow(notifier).to receive(:notification_found_in_settings?).with('telegram') { false }
        expect(TimeTrackerExtension::Notifiers::Telegram).to_not receive(:new)
        notifier.send(:notify_by_telegram)
      end

      it "should build new telegram notifier" do
        allow(user).to receive(:telegram_id) { 1 }
        allow(notifier).to receive(:notification_found_in_settings?).with('telegram') { true }
        expect(TimeTrackerExtension::Notifiers::Telegram).to receive(:new).with(user, {}) { double(send: true) }
        notifier.send(:notify_by_telegram)
      end

      it "should send message according to the notification type" do
        allow(user).to receive(:telegram_id) { 1 }
        allow(notifier).to receive(:notification_found_in_settings?).with('telegram') { true }
        telegram_notifier = double
        allow(TimeTrackerExtension::Notifiers::Telegram).to receive(:new).with(user, {}) { telegram_notifier }
        expect(telegram_notifier).to receive(:send).with(:approve_period)
        notifier.send(:notify_by_telegram)
      end
    end

  end
end
