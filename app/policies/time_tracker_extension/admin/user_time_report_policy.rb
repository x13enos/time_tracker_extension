module TimeTrackerExtension
  module Admin

    class UserTimeReportPolicy < ApplicationPolicy
      def index?
        user_is_manager?
      end

      def update?
        user_is_manager?
      end
    end

  end
end
