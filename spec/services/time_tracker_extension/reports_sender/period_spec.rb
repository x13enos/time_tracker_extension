require "rails_helper"

module TimeTrackerExtension
  RSpec.describe ReportsSender::Period do
    let!(:admin) { create(:user, :admin) }
    let!(:workspace) { admin.active_workspace }
    let!(:staff) { create(:user, :staff, active_workspace: workspace) }

    it "should return false if not all users approved the same time locking period" do
      travel_to Date.today.beginning_of_week
      period_params = {
        workspace_id: workspace.id,
        beginning_of_period: Date.today.beginning_of_week,
        end_of_period: Date.today.end_of_week,
        approved: false
      }
      admin.time_locking_periods.create(period_params)
      staff.time_locking_periods.create(period_params)
      expect(TimeTrackerExtension::ReportsSender::Period.new(admin.time_locking_periods.last).perform).to be_falsey
      travel_back
    end

    context "all users approved their reports for particular time period" do
      let!(:period) do
        create(
          :time_locking_period,
          user: admin,
          workspace_id: workspace.id,
          beginning_of_period: Date.today.beginning_of_week,
          end_of_period: Date.today.end_of_week,
          approved: true
        )
      end

      before do
        users = [admin]
        allow(users).to receive(:where) { users }
        allow(period).to receive(:workspace) { workspace }
        allow(workspace).to receive(:users) { users }
      end

      it "should return data based on user's time records for specific period time" do
        selector = double(perform: {})
        users = [admin]
        allow(users).to receive(:where) { users }
        allow(period).to receive(:workspace) { workspace }
        allow(workspace).to receive(:users) { users }
        expect(TimeRecordsSelector).to receive(:new).with({
          from_date: period.beginning_of_period,
          to_date: period.end_of_period,
          workspace_id: period.workspace_id
        }, admin).and_return(selector)
        allow(ReportGenerator).to receive(:new) { double(file: Tempfile.new) }
        TimeTrackerExtension::ReportsSender::Period.new(period).perform
      end

      it "should generate reports base on the selected data" do
        time_records_data = double
        selector = double(:perform)
        allow(TimeRecordsSelector).to receive(:new) { double(perform: time_records_data) }
        expect(ReportGenerator).to receive(:new).with(time_records_data, admin) { double(file: Tempfile.new) }
        TimeTrackerExtension::ReportsSender::Period.new(period).perform
      end

      it "should send email to admin with reports" do
        file = Tempfile.new
        allow(ReportGenerator).to receive(:new) { double(file: file) }
        expect(::UserNotifier).to receive(:new).with({
          user: admin,
          notification_type: :period_reports,
          additional_data: { reports: { admin.name => file }, period: period },
          workspace_id: period.workspace_id
        }) { double(perform: true) }
        TimeTrackerExtension::ReportsSender::Period.new(period).perform
      end
    end

  end
end
