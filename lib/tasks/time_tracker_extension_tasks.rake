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

  desc 'Run poller. It broadcasts Rails.logger to STDOUT in dev like `rails s` do. ' \
    'Use LOG_TO_STDOUT to enable/disable broadcasting.'
  task :telegram_bot_poller do
    ENV['BOT_POLLER_MODE'] = 'true'
    Rake::Task['environment'].invoke
    if ENV.fetch('LOG_TO_STDOUT') { Rails.env.development? }.present?
      console = ActiveSupport::Logger.new(STDERR)
      Rails.logger.extend ActiveSupport::Logger.broadcast console
    end
    Telegram::Bot::UpdatesPoller.start(ENV['BOT'].try!(:to_sym) || :default)
  end
end
