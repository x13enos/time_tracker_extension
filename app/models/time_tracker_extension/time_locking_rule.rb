module TimeTrackerExtension
  class TimeLockingRule < ApplicationRecord
    belongs_to :workspace

    enum period: { weekly: 0, monthly: 1 }

    validates :period, presence: true
  end
end
