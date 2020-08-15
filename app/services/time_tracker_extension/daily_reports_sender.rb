module TimeTrackerExtension
  class DailyReportsSender
    class << self

      def execute
        # TODO: change this with checking which admins have notification setting about sending daily reports,
        # select workspaces based on that info
        Workspace.all.each do |workspace|
          create_reports(workspace)
        end
      end

      private

      def create_reports(workspace)
        report_data = {
          workspace_name: workspace.name,
          users_data: users_data(workspace)
        }
        workspace.users.where("users_workspaces.role = ?", UsersWorkspace.roles["admin"]).each do |admin|
          ::UserNotifier.new(admin, :daily_report, { report_data: report_data }).perform
        end
      end

      def users_data(workspace)
        workspace.users.inject({}) do |data, user|
          tasks = workspace.time_records.where(user_id: user.id, assigned_date: Date.yesterday)
          data[user.id] = {
            name: user.name,
            tasks_count: tasks.size,
            total_time: tasks.sum(:spent_time)
          }
          data
        end
      end

    end
  end
end
