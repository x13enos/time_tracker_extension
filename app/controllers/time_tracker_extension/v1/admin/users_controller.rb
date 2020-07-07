module TimeTrackerExtension

  class V1::Admin::UsersController < ::V1::BaseController

    def index
      authorize([:time_tracker_extension, :admin, :user])
      @users = User.
              includes(:workspaces).
              where(workspaces: { id:  current_workspace_id } )
    end

  end

end
