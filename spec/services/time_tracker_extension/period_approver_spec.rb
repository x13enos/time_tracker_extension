require "rails_helper"

module TimeTrackerExtension
  RSpec.describe PeriodApprover do
    let!(:period) { create(:time_locking_period) }

    describe ".initialize" do
      it "should assign period to the instance attribute" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        expect(approver.period).to eq(period)
      end
    end

    describe "#perform" do
      it "should return true if period was approved" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        allow(period).to receive(:update).with(approved: true) { true }
        expect(approver.perform).to be_truthy
      end

      it "should call job for sending reports to admins in case of period was approved" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        allow(period).to receive(:update).with(approved: true) { true }
        expect(TimeTrackerExtension::SendPeriodReportsJob).to receive(:perform_later).with(period)
        approver.perform
      end

      it "should return false if period was not approved" do
        approver = TimeTrackerExtension::PeriodApprover.new(period)
        allow(period).to receive(:update).with(approved: true) { false }
        expect(approver.perform).to be_falsey
      end
    end

  end
end
