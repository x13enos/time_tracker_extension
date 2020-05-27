FactoryBot.define do

  factory :time_locking_rule, class: TimeTrackerExtension::TimeLockingRule do
    association :workspace
    period { 0 }
  end

end

