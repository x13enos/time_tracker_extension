require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::Admin::UsersController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }
    login_user(:admin)

    describe "GET #index" do
      it "should return list of users" do
        workspace = create(:workspace, users: [@current_user])
        workspace_2 = create(:workspace)

        allow(controller).to receive(:current_workspace_id) { workspace.id }
        controller.instance_variable_set(:@current_workspace_id, workspace.id)

        user = create(:user, active_workspace: workspace_2, workspaces: [workspace_2])
        user_2 = create(:user, active_workspace: workspace_2, workspaces: [workspace, workspace_2])

        get :index, params: { format: :json }
        expect(response.body).to eq([
          {
            id: @current_user.id,
            name: @current_user.name,
            email: @current_user.email,
            role: @current_user.role(workspace.id)
          },
          {
            id: user_2.id,
            name: user_2.name,
            email: user_2.email,
            role: user_2.role(workspace.id)
          },
        ].to_json)
      end
    end
  end
end
