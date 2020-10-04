module TimeTrackerExtension
  module TimeLockingPeriods
    class BaseForm
      include ActiveModel::Model

      ATTRIBUTES = %w[approved beginning_of_period end_of_period user_id
                      workspace_id created_at updated_at]

      attr_accessor *ATTRIBUTES
      attr_accessor :id, :user, :workspace, :period

    end
  end
end
