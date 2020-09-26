require "rails_helper"

module TimeTrackerExtension
  module TelegramMessageGenerators
    RSpec.describe TodayTasks do
      let!(:user) { create(:user) }
      let!(:project) { create(:project, workspace: user.active_workspace) }
      let!(:project_2) { create(:project, workspace: user.active_workspace) }

      let!(:time_record) { create(:time_record, user: user, project: project, assigned_date: Date.today) }
      let!(:time_record_2) { create(:time_record, user: user, project: project_2, assigned_date: Date.today) }
      let!(:time_record_3) { create(:time_record, user: user, project: project, assigned_date: Date.today - 2.days) }
      let!(:time_record_4) { create(:time_record, project: project, assigned_date: Date.today) }
      let!(:time_record_5) { create(:time_record, user: user, assigned_date: Date.today) }

      it "should generate message for selected records" do
        message = I18n.t("telegram.today_tasks.body", workspace: user.active_workspace.name)
        message << "\n#{project.name}:\n"
        message << I18n.t('telegram.today_tasks.time_record_data', description: time_record.description, time: time_record.calculated_spent_time)
        message << "\n#{project_2.name}:\n"
        message << I18n.t('telegram.today_tasks.time_record_data', description: time_record_2.description, time: time_record_2.calculated_spent_time)
        message << I18n.t('telegram.today_tasks.total_time', total_time: [time_record, time_record_2].map(&:calculated_spent_time).sum)

        expect(TimeTrackerExtension::TelegramMessageGenerators::TodayTasks.new(user).perform).to eq(message)
      end

      it "should generate the specific message if selected time records belong to one project" do\
        time_record_2.update(project_id: project.id)

        message = I18n.t("telegram.today_tasks.body", workspace: user.active_workspace.name)
        message << "\n"
        message << I18n.t('telegram.today_tasks.time_record_data', description: time_record.description, time: time_record.calculated_spent_time)
        message << I18n.t('telegram.today_tasks.time_record_data', description: time_record_2.description, time: time_record_2.calculated_spent_time)
        message << I18n.t('telegram.today_tasks.total_time', total_time: [time_record, time_record_2].map(&:calculated_spent_time).sum)

        expect(TimeTrackerExtension::TelegramMessageGenerators::TodayTasks.new(user).perform).to eq(message)
      end
    end
  end
end
