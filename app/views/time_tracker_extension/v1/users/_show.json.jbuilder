json.(user, :id, :email, :name, :role, :locale, :active_workspace_id, :telegram_token)

json.telegram_active user.telegram_id.present?
json.unapproved_periods user.unapproved_periods do |period|
  json.id period.id
  json.from period.beginning_of_period.strftime("%d/%m/%Y")
  json.to period.end_of_period.strftime("%d/%m/%Y")
end

json.notification_settings user.notification_settings.rules
