class Notifiers::Base
  def initialize(user, args)
    @user = user
    @args = args
  end

  private
  attr_reader :user, :args
end
