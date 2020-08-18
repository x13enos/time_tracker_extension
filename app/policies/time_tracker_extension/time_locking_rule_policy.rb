module TimeTrackerExtension
  class TimeLockingRulePolicy < ApplicationPolicy
    def index?
      user? && workspace_belongs_to_user?
    end

    def create?
      user? && workspace_belongs_to_user?
    end

    def destroy?
      user? && workspace_belongs_to_user?
    end
  end
end
