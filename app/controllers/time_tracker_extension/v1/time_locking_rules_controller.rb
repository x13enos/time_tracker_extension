module TimeTrackerExtension
  class V1::TimeLockingRulesController < ::V1::BaseController
    def index
      authorize workspace, policy_class: TimeTrackerExtension::TimeLockingRulePolicy
      @time_locking_rules = TimeLockingRule.where(workspace_id: params[:workspace_id])
    end

    def create
      validate_workspace_id and return
      authorize workspace, policy_class: TimeTrackerExtension::TimeLockingRulePolicy
      @time_locking_rule = TimeLockingRule.new(rule_params)
      @time_locking_rule.save
      generate_response
    end

    def destroy
      authorize time_locking_rule.workspace, policy_class: TimeTrackerExtension::TimeLockingRulePolicy
      time_locking_rule.destroy
      generate_response
    end

    private

    def generate_response
      if time_locking_rule.errors.empty?
        render partial: 'time_tracker_extension/v1/time_locking_rules/show.json.jbuilder', locals: { rule: time_locking_rule }
      else
        render json: { errors: time_locking_rule.errors }, status: 400
      end
    end

    def time_locking_rule
      @time_locking_rule ||= TimeLockingRule.where("workspace_id IN (?)", current_user.workspace_ids).find_by(id: params[:id])
    end

    def validate_workspace_id
      return false if current_user.workspace_ids.include?(params[:workspace_id].to_i)
      render(
        json: { errors: { base: I18n.t("time_locking_rules.user_does_not_have_access_to_workspace") } },
        status: 400
      )
    end

    def rule_params
      params.permit(:period, :workspace_id)
    end

    def workspace
      @workspace ||= current_user.workspaces.find(params[:workspace_id])
    end
  end
end
