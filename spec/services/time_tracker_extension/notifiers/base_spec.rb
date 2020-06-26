require "rails_helper"

module TimeTrackerExtension
  RSpec.describe Notifiers::Base do
    let(:user) { create(:user) }

    describe ".initialize" do
      let!(:notifier) { TimeTrackerExtension::Notifiers::Base.new(user, { period: "period" }) }

      it "should assign user to the notifier's attributes" do
        expect(notifier.send(:user)).to eq(user)
      end

      it "should assign additional args to the notifier's attributes" do
        expect(notifier.send(:args)).to eq({ period: "period" })
      end
    end
  end
end
