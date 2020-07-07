module TimeTrackerExtension
  module Admin

    class UserTimeReportPolicy < ApplicationPolicy
      def index?
        user_is_admin?
      end

      def update?
        user_is_admin?
      end
    end

  end
end
