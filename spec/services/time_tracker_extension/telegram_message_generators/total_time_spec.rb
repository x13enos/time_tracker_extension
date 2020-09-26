require "rails_helper"

module TimeTrackerExtension
  module TelegramMessageGenerators
    RSpec.describe TotalTime do
      let!(:user) { create(:user) }
      let!(:project) { create(:project, workspace: user.active_workspace) }
      let!(:beginning_of_month) { Date.today.beginning_of_month }

      let!(:time_record) { create(:time_record, user: user, project: project, assigned_date: beginning_of_month, spent_time: 1) }
      let!(:time_record_2) { create(:time_record, user: user, project: project, assigned_date: beginning_of_month + 13.days, spent_time: 2.25) }

      it "should return time and number of tasks for current month" do
        message = I18n.t("telegram.total_time.time_and_number", number: 2, time: 3.25, period: 'month')
        expect(TimeTrackerExtension::TelegramMessageGenerators::TotalTime.new(user, 'month').perform).to eq(message)
      end

      it "should return time and number of tasks for current week" do
        travel_to beginning_of_month + 13.days
        message = I18n.t("telegram.total_time.time_and_number", number: 1, time: 2.25, period: 'week')
        expect(TimeTrackerExtension::TelegramMessageGenerators::TotalTime.new(user, 'week').perform).to eq(message)
        travel_back
      end
    end
  end
end
