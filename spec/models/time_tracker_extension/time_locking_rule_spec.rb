require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe TimeLockingRule, type: :model do

    context "validations" do
      it { should validate_presence_of(:period) }
    end

    context "associations" do
      it { should belong_to(:workspace)  }
      it { should have_many(:users).through(:workspace)  }
    end
  end
end
