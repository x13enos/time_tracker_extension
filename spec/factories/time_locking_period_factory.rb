FactoryBot.define do

  factory :time_locking_period, class: TimeTrackerExtension::TimeLockingPeriod do
    association :workspace
    association :user
    beginning_of_period { Date.today }
    end_of_period { Date.today  }
    approved { false }
  end

end

