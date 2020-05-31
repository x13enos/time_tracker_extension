class V1::TimeRecordsController < V1::BaseController

  def index
    @current_date = params[:assigned_date].to_datetime
    @time_records = []
  end

end
