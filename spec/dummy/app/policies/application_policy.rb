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

  def record_belongs_to_user?
    record.belongs_to_user?(user.id)
  end

end

