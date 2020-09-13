class TimeTrackerExtension::UserMailer < ApplicationMailer
  def approve_time_locking_period(user, period)
    @user = user
    @period = period
    @token = TokenCryptService.encode(@user.email, 24.hours)
    mail(to: @user.email, subject: I18n.t("mailers.subjects.approve_your_timereport"))
  end

  def period_reports(recipient, reports, period)
    @recipient = recipient
    @period = period
    reports.each do |user_name, file|
      attachments["#{user_name} #{period.beginning_of_period} | #{period.end_of_period}.pdf"] = File.read(file)
    end
    mail(
      to: @recipient.email,
      subject: I18n.t(
        "mailers.subjects.period_reports",
        workspace: @period.workspace.name,
        from: @period.beginning_of_period,
        to: @period.end_of_period
      )
    )
  end
end
