require "rails_helper"

module TimeTrackerExtension
  RSpec.describe BlockedDaysSearcher do
    let!(:workspace) { create(:workspace) }
    let!(:user) { create(:user) }
    let!(:date) { "31-05-2020".to_datetime }

    before do
      workspace.users << [user]
    end

    it "should find intersection between approved periods and current week" do
      period_1 = create(:time_locking_period,
        workspace: workspace,
        user: user, approved:
        true,
        beginning_of_period: "25-05-2020".to_datetime,
        end_of_period: "27-05-2020".to_datetime
      )

      period_2 = create(:time_locking_period,
        workspace: workspace,
        user: user, approved:
        true,
        beginning_of_period: "01-05-2020".to_datetime,
        end_of_period: "30-05-2020".to_datetime
      )

      result = TimeTrackerExtension::BlockedDaysSearcher.new(user, workspace.id, date).perform
      expect(result).to eql([
        "25-05-2020".to_datetime,
        "26-05-2020".to_datetime,
        "27-05-2020".to_datetime,
        "28-05-2020".to_datetime,
        "29-05-2020".to_datetime,
        "30-05-2020".to_datetime
        ])
    end
  end
end
