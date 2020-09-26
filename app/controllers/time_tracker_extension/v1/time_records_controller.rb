module TimeTrackerExtension
  class V1::TimeRecordsController < ::V1::TimeRecordsController

    def index
      super
      @blocked_days = TimeTrackerExtension::BlockedDaysSearcher.new(current_user,
                                                                    current_workspace_id,
                                                                    @active_date).perform
    end

  end
end
