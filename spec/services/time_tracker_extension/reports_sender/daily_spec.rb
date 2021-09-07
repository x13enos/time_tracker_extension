require "rails_helper"

module TimeTrackerExtension
  RSpec.describe ReportsSender::Daily do
    let!(:admin) { create(:user, :admin) }
    let!(:workspace) { admin.active_workspace }
    let!(:project) { create(:project, workspace: workspace) }
    let!(:staff) { create(:user, :staff) }
    let(:report_data) do
      {
        workspace_name: workspace.name,
        users_data: {
          admin.id => {
            name: admin.name,
            tasks_count: 2,
            total_time: 3
          },
          staff.id => {
            name: staff.name,
            tasks_count: 1,
            total_time: 0.5
          }
        }
      }
    end

    it "should collect and send info to admins about users and their tasks for yesterday" do
      travel_to Date.today.beginning_of_month

      create(:time_record, assigned_date: Date.yesterday, spent_time: 2, user: admin, workspace: workspace)
      create(:time_record, assigned_date: Date.yesterday, spent_time: 1, user: admin,workspace: workspace)
      create(:time_record, assigned_date: Date.yesterday - 1.day, spent_time: 5, user: admin, workspace: workspace)
      create(:time_record, assigned_date: Date.yesterday, spent_time: 2, user: admin)

      create(:time_record, assigned_date: Date.yesterday, spent_time: 0.5, user: staff, workspace: workspace)
      create(:time_record, assigned_date: Date.yesterday, spent_time: 2, user: admin)

      workspace.users << [staff]
      allow(workspace).to receive_message_chain(:users, :where) { [admin] }
      expect(::UserNotifier).to receive(:new).with({
        user: admin,
        notification_type: :daily_report,
        additional_data: { report_data: report_data },
        workspace_id: workspace.id
      }) { double(perform: true) }
      TimeTrackerExtension::ReportsSender::Daily.execute
      travel_back
    end

  end
end
