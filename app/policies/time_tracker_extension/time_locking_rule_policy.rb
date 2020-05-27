module TimeTrackerExtension
  class TimeLockingRulePolicy < ApplicationPolicy
    def index?
      user_is_admin?
    end

    def create?
      user_is_admin?
    end

    def update?
      user_is_admin?
    end

    def destroy?
      user_is_admin?
    end
  end
end
