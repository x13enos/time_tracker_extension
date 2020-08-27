module TimeTrackerExtension
  module Users
    module CreateFormExtension

      private

      def user_attributes
        super.merge({ telegram_token: SecureRandom.hex})
      end

    end
  end
end
