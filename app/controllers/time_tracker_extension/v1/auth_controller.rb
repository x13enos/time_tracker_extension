module TimeTrackerExtension
  class V1::AuthController < ::V1::BaseController
    skip_before_action :authenticate
    skip_after_action :set_token

    def index
      if current_user
        render partial: 'time_tracker_extension/v1/users/show.json.jbuilder', locals: {
          user: current_user,
          unapproved_periods: select_pending_periods
        }
      else
        render json: { error: I18n.t("auth.errors.unathorized") }, status: 401
      end
    end

    private

    def select_pending_periods
      current_user.time_locking_periods.where(
        "workspace_id = ? AND approved = false AND end_of_period < ?",
        current_workspace_id, Date.today
      )
    end
  end
end
