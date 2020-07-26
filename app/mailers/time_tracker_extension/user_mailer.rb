class TimeTrackerExtension::UserMailer < ApplicationMailer
  def approve_time_locking_period(user, period)
    @user = user
    @period = period
    @token = TokenCryptService.encode(@user.email, 24.hours)
    mail(to: @user.email, subject: I18n.t("mailers.subjects.approve_your_timereport"))
  end
end
