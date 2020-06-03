module Helpers
  def login_admin
    before(:each) do
     @current_user = FactoryBot.create(:user, role: :admin)
     allow(controller).to receive(:current_user) { @current_user }
     allow(controller).to receive(:current_workspace_id) { @current_user.active_workspace_id }
    end
  end

  def login_staff
    before(:each) do
     @current_user = FactoryBot.create(:user, role: :staff)
     allow(controller).to receive(:current_user) { @current_user }
     allow(controller).to receive(:current_workspace_id) { @current_user.active_workspace_id }
    end
  end
end

RSpec.configure do |config|
  config.extend Helpers, type: :controller
end
