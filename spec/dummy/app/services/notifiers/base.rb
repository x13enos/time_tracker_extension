class Notifiers::Base
  def initialize(user, additional_data)
    @user = user
    @additional_data = additional_data
  end

  private
  attr_reader :user, :additional_data
end
