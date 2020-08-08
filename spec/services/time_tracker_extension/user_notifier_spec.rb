require "rails_helper"

class DummyNotifier
  prepend TimeTrackerExtension::UserNotifier
  def initialize(user, notification_type, args)
    @user = user
    @args = args
    @notification_type = notification_type
  end

  private
  attr_reader :user, :notification_type, :args

  def notifications
  end

  def send_notification(notification_class)
  end

  def notification_found_in_settings(notification_type)
  end
end

module TimeTrackerExtension
  RSpec.describe UserNotifier do
    let!(:user) { create(:user) }
    let!(:notifier) { DummyNotifier.new(user, :approve_period, { period: "period" }) }

    describe "notifications" do

      it "should call method 'notify_by_email'" do
        expect(notifier).to receive(:notify_by_email)
        notifier.send(:notifications)
      end

      it "should not call method if user doesn't have notification setting" do
        allow(notifier).to receive(:notify_by_email)
        allow(user).to receive(:telegram_id) { 111 }
        allow(notifier).to receive(:notification_found_in_settings) { false }
        notifier.send(:notifications)
      end

      context "all checks were passed" do
        before do
          allow(notifier).to receive(:notify_by_email)
          allow(user).to receive(:telegram_id) { 111 }
          allow(notifier).to receive(:notification_found_in_settings) { true }
        end

        it "should call method for creating specific notifier" do
          expect(TimeTrackerExtension::Notifiers::Telegram).to receive(:new).with(user, { period: "period" }) { double(approve_period: true) }
          notifier.send(:notifications)
        end

        it "should send cnotification via specific notifier" do
          telegram_notifier = double
          allow(TimeTrackerExtension::Notifiers::Telegram).to receive(:new).with(user, { period: "period" }) { telegram_notifier }
          expect(telegram_notifier).to receive(:approve_period)
          notifier.send(:notifications)
        end
      end
    end
  end
end
