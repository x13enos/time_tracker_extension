class UserNotifier

  def initialize(notification_data)
    @user = notification_data[:user]
    @additional_data = notification_data[:additional_data]
    @notification_type = notification_data[:notification_type]
    @workspace_id = notification_data[:workspace_id]
  end

  def perform
  end

end
