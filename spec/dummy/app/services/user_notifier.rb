class UserNotifier

  def initialize(user, notification_type, args)
    @user = user
    @args = args
    @notification_type = notification_type
  end

  def perform
  end
  
end
