require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::TimeLockingRulesController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }

    describe "GET #index" do
      it "should return list of workspace's time locking rules" do

        workspace = create(:workspace)
        login_user(:owner, workspace)
        workspace_2 = create(:workspace)

        rule = create(:time_locking_rule, period: 0, workspace: workspace)
        rule_2 = create(:time_locking_rule, period: 1,  workspace: workspace_2)
        rule_3 = create(:time_locking_rule, period: 1)

        get :index, params: { workspace_id: workspace.id, format: :json }
        expect(response.body).to eq([
          {
            id: rule.id,
            period: rule.period
          }
        ].to_json)
      end
    end

    describe "POST #create" do
      let(:workspace) { create(:workspace) }

      before do
        login_user(:owner, workspace)
      end

      it "should return error if passed workspace doesn't belong to user" do
        workspace_2 = create(:workspace)
        post(:create, params: { period: "weekly", workspace_id: workspace_2.id, format: :json })
        expect(response.body).to eq(
           { errors: { base: "User doesn't have access to that workspace" }}.to_json
        )
      end

      it "should create new time locking rule" do
        expect{ post(:create, params: { period: "monthly", workspace_id: workspace.id, format: :json }) }.to change{ TimeLockingRule.count }.from(0).to(1)
      end

      it "should return data of created user" do

        post(:create, params: { period: "weekly", workspace_id: workspace.id, format: :json })
        expect(response.body).to eq(
          {
            id: TimeLockingRule.last.id,
            period: "weekly",
            workspace_id: workspace.id
          }.to_json
        )
      end

      it "should return errors in case of fail" do
        post(:create, params: { period: "", workspace_id: workspace.id, format: :json })
        expect(response.body).to eq(
          {
            errors: {
              period: ["can't be blank"]
            }
          }.to_json
        )
      end
    end

    describe "DELETE #destroy" do
      login_user(:owner)
      let!(:time_locking_rule) { create(:time_locking_rule, workspace: @current_user.active_workspace) }

      it "should return rule's data if it was deleted" do
        delete :destroy, params: { id: time_locking_rule.id, format: :json }
        expect(response.body).to eq({
          id: time_locking_rule.id,
          period: time_locking_rule.period,
          workspace_id: time_locking_rule.workspace_id
        }.to_json)
      end

      it "should remove rule" do
        expect { delete :destroy, params: { id: time_locking_rule.id, format: :json } }.to change { TimeLockingRule.count }.from(1).to(0)
      end

      it "should return error message if rule wasn't deleted" do
        allow(TimeLockingRule).to receive_message_chain(:where, :find_by) { time_locking_rule }
        allow(time_locking_rule).to receive(:destroy) { false }
        time_locking_rule.errors.add(:base, "can't delete")
        delete :destroy, params: { id: time_locking_rule.id, format: :json }
        expect(response.body).to eq({ errors: { base: ["can't delete"] } }.to_json)
      end
    end

  end
end
