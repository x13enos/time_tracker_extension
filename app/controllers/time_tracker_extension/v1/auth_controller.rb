module TimeTrackerExtension
  class V1::AuthController < ::V1::BaseController
    include TimeTrackerExtension::ViewHelpers

    skip_before_action :authenticate
    skip_after_action :set_token

    def index
      if current_user
        render_json_partial('/v1/auth/user.json.jbuilder', { user: current_user })
      else
        render json: { error: I18n.t("auth.errors.unathorized") }, status: 401
      end
    end

  end
end
