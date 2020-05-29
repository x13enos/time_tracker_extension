module TimeTrackerExtension
  class TimeLockingPeriod < ApplicationRecord
    belongs_to :workspace
    belongs_to :user

    validates :beginning_of_period, :end_of_period, presence: true
  end
end
