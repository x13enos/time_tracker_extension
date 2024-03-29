module TimeTrackerExtension
  class V1::TimeLockingPeriodsController < ::V1::BaseController
    skip_before_action :authenticate
    skip_after_action :set_token

    def update
      user = User.find_by(email: decode(token))
      if user
        approve_time_locking_period(user)
      else
        render json: { errors: { base: [I18n.t("time_locking_periods.link_is_expired")] } }, status: 404
      end
    end

    private

    def approve_time_locking_period(user)
      period = user.time_locking_periods.where(workspace_id: workspace_id).find(params[:id])
      form = TimeTrackerExtension::TimeLockingPeriods::UpdateForm.new({ approved: true }, period)
      if form.save
        render json: { status: 'ok' }, status: 200
      else
        render json: { errors: form.errors, dates: form.dates_of_invalid_time_records }, status: 400
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
