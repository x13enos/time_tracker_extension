require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe TimeLockingPeriod, type: :model do

    context "validations" do
      it { should validate_presence_of(:beginning_of_period) }
      it { should validate_presence_of(:end_of_period) }
    end

    context "associations" do
      it { should belong_to(:workspace)  }
      it { should belong_to(:user) }
    end
  end
end
