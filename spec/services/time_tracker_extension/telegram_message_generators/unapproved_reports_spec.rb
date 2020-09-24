require "rails_helper"

module TimeTrackerExtension
  module TelegramMessageGenerators
    RSpec.describe UnapprovedReports do
      let!(:user) { create(:user) }
      let!(:project) { create(:project, workspace: user.active_workspace) }
      let!(:beginning_of_month) { (Date.today - 1.month).beginning_of_month }

      context "users have some unapproved reports" do
        let!(:period) do
          create(:time_locking_period,
                 user: user,
                 workspace: user.active_workspace,
                 approved: false,
                 beginning_of_period: beginning_of_month,
                 end_of_period: beginning_of_month.end_of_month)
        end

        let!(:period_2) do
          create(:time_locking_period,
                 user: user,
                 workspace: user.active_workspace,
                 approved: false,
                 beginning_of_period: (beginning_of_month + 14.days).beginning_of_week,
                 end_of_period: (beginning_of_month + 14.days).end_of_week)
        end

        it "should return generated message base on the selected periods" do
          message = I18n.t("telegram.unapproved_reports.body", workspace: user.active_workspace.name)

          message << "#{I18n.t('telegram.unapproved_reports.period_range', period: "#{period.beginning_of_period} | #{period.end_of_period}")}"
          message << I18n.t('telegram.unapproved_reports.user_name', name: user.name)

          message << "#{I18n.t('telegram.unapproved_reports.period_range', period: "#{period_2.beginning_of_period} | #{period_2.end_of_period}")}"
          message << I18n.t('telegram.unapproved_reports.user_name', name: user.name)

          expect(TimeTrackerExtension::TelegramMessageGenerators::UnapprovedReports.new(user).perform).to eq(message)
        end
      end


      it "should return message in case of all reports were approved" do
        message = I18n.t("telegram.unapproved_periods.no_reports")
        expect(TimeTrackerExtension::TelegramMessageGenerators::UnapprovedReports.new(user).perform).to eq(message)
      end
    end
  end
end
