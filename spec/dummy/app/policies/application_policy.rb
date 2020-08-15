class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def user?
    user.present?
  end

  def user_is_admin?
    user? && user.try(:admin?)
  end

  def user_is_owner?
    user? && user.try(:owner?)
  end

  def user_is_manager?
    user_is_admin? || user_is_owner?
  end

  def record_belongs_to_user?
    record.belongs_to_user?(user.id)
  end

  def workspace_belongs_to_user?
    user.owner_for_workspace?(record.id)
  end

end
