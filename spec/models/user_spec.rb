require 'rails_helper'

RSpec.describe Workspace, type: :model do

  context "associations" do
    it { should have_many(:time_locking_periods).dependent(:destroy)  }
  end

  describe "unapproved_periods" do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user, active_workspace: workspace) }
    let!(:period_1) { create(:time_locking_period, workspace: workspace, user: user, approved: true, end_of_period: Date.today - 1.week) }
    let!(:period_2) { create(:time_locking_period, workspace: workspace, user: user, approved: false, end_of_period: Date.today) }
    let!(:period_3) { create(:time_locking_period, workspace: workspace, user: user, approved: false, end_of_period: Date.today - 2.days) }

    it "should return periods for current workspace and which weren't approve" do
      expect(user.unapproved_periods).to eq([period_3])
    end
  end

end
