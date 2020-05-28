namespace :time_tracker_extension do
  desc "build time locking period for users"
  task build_time_locking_period: :environment do
    time = Time.now
    TimeTrackerExtension::TimeLockingPeriodsBuilder.execute
    puts "Task was finished for #{ (Time.now - time).round } seconds"
  end
end
