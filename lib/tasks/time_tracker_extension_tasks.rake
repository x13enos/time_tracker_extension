namespace :time_tracker_extension do
  desc "build time locking period for users"
  task build_time_locking_periods: :environment do
    time = Time.now
    TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
    puts "Task was finished for #{ (Time.now - time).round } seconds"
  end

  desc "check locking periods and notify users"
  task check_time_locking_periods: :environment do
    time = Time.now
    TimeTrackerExtension::TimeLockingPeriodsChecker.execute
    puts "Task was finished for #{ (Time.now - time).round } seconds"
  end

  desc "send_daily reports to admins"
  task send_daily_reports: :environment do
    time = Time.now
    TimeTrackerExtension::ReportsSender::Daily.execute
    puts "Task was finished for #{ (Time.now - time).round } seconds"
  end

  desc 'Run poller. It broadcasts Rails.logger to STDOUT in dev like `rails s` do. ' \
    'Use LOG_TO_STDOUT to enable/disable broadcasting.'
  task telegram_bot_poller: :environment do
    ENV['BOT_POLLER_MODE'] = 'true'
    Rake::Task['environment'].invoke
    if ENV.fetch('LOG_TO_STDOUT') { Rails.env.development? }.present?
      console = ActiveSupport::Logger.new(STDERR)
      Rails.logger.extend ActiveSupport::Logger.broadcast console
    end
    Telegram::Bot::UpdatesPoller.start(ENV['BOT'].try!(:to_sym) || :default)
  end

  desc 'Set telegram webhook urls for all bots'
  task set_telegram_webhook: :environment do
    routes = TimeTrackerExtension::Engine.routes.url_helpers
    cert_file = ENV['CERT']
    cert = File.open(cert_file) if cert_file
    Telegram.bots.each do |key, bot|
      route_name = Telegram::Bot::RoutesHelper.route_name_for_bot(bot)
      url = routes.send("#{route_name}_url")
      puts "Setting webhook for #{key}..."
      bot.async(false) { bot.set_webhook(url: url, certificate: cert) }
    end
  end
end
