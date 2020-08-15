require 'rails_helper'

module TimeTrackerExtension
  module Admin

    describe UserPolicy do

      context 'user is admin' do
        let(:user) { create(:user, :admin) }

        subject { described_class.new(user, :user) }

        it { is_expected.to permit_action(:index) }
      end

      context 'user is staff' do
        let(:user) { create(:user, :staff) }

        subject { described_class.new(user, :user) }

        it { is_expected.to forbid_action(:index) }
      end
    end

  end
end
