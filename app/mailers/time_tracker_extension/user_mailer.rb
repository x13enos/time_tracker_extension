class TimeTrackerExtension::UserMailer < ApplicationMailer
  def approve_time_locking_period(period)
    @period = period
    @user = period.user
    @token = TokenCryptService.encode(@user.email, 24.hours)
    mail(to: @user.email, subject: I18n.t("mailers.approve_your_timereport"))
  end
end
