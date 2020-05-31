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
end
