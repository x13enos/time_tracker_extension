module TimeTrackerExtension
  class V1::TimeLockingPeriodsController < ::V1::BaseController
    skip_before_action :authenticate
    skip_after_action :set_token

    def update
      user = User.find_by(email: decode(token))
      if user
        approve_time_locking_period(user)
      else
        render json: { errors: { base: I18n.t("time_locking_periods.invalid_token") } }, status: 404
      end
    end

    private

    def approve_time_locking_period(user)
      time_locking_period = user.time_locking_periods.where(workspace_id: workspace_id).find(params[:id])
      if time_locking_period.approve!
        render json: { status: 'ok' }, status: 200
      else
        render json: { errors: time_locking_period.errors }, status: 400
      end
    end

    def token
      (params[:token] || cookies[:token]).to_s
    end

    def workspace_id
      current_workspace_id || params[:workspace_id]
    end

  end
end
