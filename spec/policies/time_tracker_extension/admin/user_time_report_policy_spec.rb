require 'rails_helper'

module TimeTrackerExtension
  module Admin

    describe UserTimeReportPolicy do

      context 'user is admin' do
        let(:user) { create(:user, :admin) }

        subject { described_class.new(user, :time_report) }

        it { is_expected.to permit_actions([:index, :update]) }
      end

      context 'user is staff' do
        let(:user) { create(:user, :staff) }

        subject { described_class.new(user, :time_report) }

        it { is_expected.to forbid_actions([:index, :update]) }
      end
    end

  end
end
