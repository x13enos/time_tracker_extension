require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::Admin::UsersController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }
    login_admin

    describe "GET #index" do
      it "should return list of users" do

        workspace = create(:workspace)
        workspace_2 = create(:workspace)

        user = create(:user, active_workspace: workspace_2, workspace_ids: [workspace_2.id])
        user_2 = create(:user, active_workspace: workspace_2, workspace_ids: [workspace.id, workspace_2.id])

        workspace.users << @current_user
        allow(controller).to receive(:current_workspace_id) { workspace.id }
        get :index, params: { format: :json }
        expect(response.body).to eq([
          {
            id: @current_user.id,
            name: @current_user.name,
            role: @current_user.role,
            email: @current_user.email
          },
          {
            id: user_2.id,
            name: user_2.name,
            role: user_2.role,
            email: user_2.email
          },
        ].to_json)
      end
    end
  end
end
