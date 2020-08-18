module TimeTrackerExtension
  module Admin

    class UserPolicy < ApplicationPolicy
      def index?
        user_is_manager?
      end
    end

  end
end
