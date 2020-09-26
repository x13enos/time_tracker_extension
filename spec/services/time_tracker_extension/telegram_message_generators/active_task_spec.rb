require "rails_helper"

module TimeTrackerExtension
  module TelegramMessageGenerators
    RSpec.describe ActiveTask do
      let!(:user) { create(:user) }
      let!(:project) { create(:project, workspace: user.active_workspace) }

      let!(:time_record) { create(:time_record, user: user, project: project, assigned_date: Date.today) }
      let!(:time_record_2) { create(:time_record, user: user, project: project, time_start: Time.now) }

      it "should generate message if user has active task" do
        button = Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t("telegram.stop"), callback_data: "stop_active_task:#{time_record_2.id}")
        allow(Telegram::Bot::Types::InlineKeyboardButton).to receive(:new) { button }
        message = {
          text: I18n.t("telegram.active_task",
                        description: time_record_2.description,
                        time: time_record_2.calculated_spent_time,
                        project: time_record_2.project.name),
          reply_markup: { inline_keyboard: [[button]] }
        }
        expect(TimeTrackerExtension::TelegramMessageGenerators::ActiveTask.new(user).perform).to eq(message)
      end

      it "should generate message if user has not active task" do
        time_record_2.update(time_start: nil)
        
        message = { text: I18n.t("telegram.active_task_is_not_found") }
        expect(TimeTrackerExtension::TelegramMessageGenerators::ActiveTask.new(user).perform).to eq(message)
      end
    end
  end
end
