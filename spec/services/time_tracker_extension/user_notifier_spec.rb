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

      it "should call method send_notification and pass telegram notifier class if user has telegram id" do
        allow(notifier).to receive(:notify_by_email)
        allow(user).to receive(:telegram_id) { 111 }
        expect(notifier).to receive(:send_notification).with(TimeTrackerExtension::Notifiers::Telegram)
        notifier.send(:notifications)
      end
    end
  end
end
