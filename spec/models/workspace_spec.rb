require 'rails_helper'

RSpec.describe Workspace, type: :model do

  context "associations" do
    it { should have_many(:time_locking_rules).dependent(:destroy)  }
    it { should have_many(:time_locking_periods).dependent(:destroy)  }
  end

end
