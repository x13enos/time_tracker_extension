require "rails_helper"

class DummyEmailNotifier
  include TimeTrackerExtension::Notifiers::Email
  def initialize(user, args)
    @user = user
    @args = args
  end

  private
  attr_reader :user, :args
end

module TimeTrackerExtension
  RSpec.describe Notifiers::Email do
    let(:user) { create(:user) }

    describe "approve_period" do
      let!(:notifier) { DummyEmailNotifier.new(user, { period: "period" }) }

      it "should build email" do
        mail = double(deliver_now: true)
        expect(TimeTrackerExtension::UserMailer).to receive(:approve_time_locking_period).with(user, "period") { mail }
        notifier.approve_period
      end

      it "should send email to user" do
        mail = double
        allow(TimeTrackerExtension::UserMailer).to receive(:approve_time_locking_period) { mail }
        expect(mail).to receive(:deliver_now)
        notifier.approve_period
      end
    end
  end
end
