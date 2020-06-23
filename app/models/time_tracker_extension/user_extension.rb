require 'securerandom'
module TimeTrackerExtension
  module UserExtension
    def self.included(klass)
      klass.class_eval do
        has_many :time_locking_periods, class_name: '::TimeTrackerExtension::TimeLockingPeriod'

        before_create :generate_telegram_token

        private

        def generate_telegram_token
          self.telegram_token = SecureRandom.hex
        end
      end
    end
  end
end
