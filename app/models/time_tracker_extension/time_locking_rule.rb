module TimeTrackerExtension
  class TimeLockingRule < ApplicationRecord
    belongs_to :workspace
    has_many :users, -> { distinct }, through: :workspace


    enum period: { weekly: 0, monthly: 1 }

    validates :period, presence: true
  end
end
