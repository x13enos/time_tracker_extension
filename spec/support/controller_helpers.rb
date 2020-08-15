module ExtendedHelpers
  def login_user(role)
    before(:each) do
     @current_user =  FactoryBot.create(:user, role)
     allow(controller).to receive(:current_user) { @current_user }
     allow(controller).to receive(:current_workspace_id) { @current_user.active_workspace_id }
     controller.instance_variable_set(:@current_workspace_id, @current_user.active_workspace_id)
    end
  end

end

module IncludedHelpers
  def login_user(role, workspace)
    @current_user =  FactoryBot.create(:user, role, active_workspace: workspace)
    allow(controller).to receive(:current_user) { @current_user }
    allow(controller).to receive(:current_workspace_id) { workspace.id }
    controller.instance_variable_set(:@current_workspace_id, workspace.id)
  end
end

RSpec.configure do |config|
  config.extend ExtendedHelpers, type: :controller
  config.include IncludedHelpers, type: :controller
end
