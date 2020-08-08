require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::Admin::TimeReportsController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }
    login_admin

    describe "GET #index" do
      it "should return list of non current time locking periods for user" do

        workspace = create(:workspace)
        workspace_2 = create(:workspace)

        user = create(:user, active_workspace: workspace, workspace_ids: [workspace.id])
        time_report = create(:time_locking_period, user: user, workspace: workspace, end_of_period: Date.today - 1.day)
        time_report_2 = create(:time_locking_period, workspace: workspace, end_of_period: Date.today - 1.day)
        time_report_3 = create(:time_locking_period, user: user, end_of_period: Date.today - 1.day)
        time_report_4 = create(:time_locking_period, user: user, workspace: workspace, end_of_period: Date.today + 1.day)

        allow(controller).to receive(:current_workspace_id) { workspace.id }
        get :index, params: { user_id: user.id, format: :json }
        expect(response.body).to eq([
          {
            id: time_report.id,
            approved: time_report.approved,
            from: time_report.beginning_of_period.strftime("%d/%m/%Y"),
            to: time_report.end_of_period.strftime("%d/%m/%Y")
          }
        ].to_json)
      end
    end

    describe "PUT #update" do
      let(:workspace) { @current_user.active_workspace }
      let!(:user) { create(:user, active_workspace: workspace, workspace_ids: [workspace.id]) }
      let!(:time_report) { create(:time_locking_period, user: user, workspace: workspace) }

      before do
        allow_any_instance_of(User).to receive_message_chain(:time_locking_periods, :where, :find) { time_report }
      end

      it "should call unblock method for time report" do
        expect(time_report).to receive(:unblock!)
        put :update, params: { user_id: user.id, id: time_report.id, format: :json }
      end

      it "should return status 200 in case of unblocking" do
        allow(time_report).to receive(:unblock!) { true }
        put :update, params: { user_id: user.id, id: time_report.id, format: :json }
        expect(response.code).to eq("200")
      end

      it "should return 400 status if time report wasn't unblock" do
        allow(time_report).to receive(:unblock!) { false }
        put :update, params: { user_id: user.id, id: time_report.id, format: :json }
        expect(response.code).to eq("400")
      end

      it "should return error message if time report wasn't unblock" do
        allow(time_report).to receive(:unblock!) { false }
        put :update, params: { user_id: user.id, id: time_report.id, format: :json }
        expect(response.body).to eq(
          { errors: { base: I18n.t("time_locking_periods.period_was_not_unblocked") } }.to_json
        )
      end
    end
  end
end
