module TimeTrackerExtension

  class V1::Admin::TimeReportsController < ::V1::BaseController
    before_action :authorize_action

    def index
      @periods = user_time_reports.where("end_of_period < ?", Date.today).order(end_of_period: :desc).limit(10)
    end

    def update
      period = user_time_reports.find(params[:id])
      if period.unblock!
        render json: { status: 'ok' }, status: 200
      else
        render json: { errors: { base: I18n.t("time_locking_periods.period_was_not_unblocked") } }, status: 400
      end
    end

    private

    def authorize_action
      authorize([:time_tracker_extension, :admin, :user_time_report])
    end

    def user_time_reports
      user = Workspace.find(current_workspace_id).users.find(params[:user_id])
      user.time_locking_periods.where(workspace_id: current_workspace_id)
    end

  end

end
