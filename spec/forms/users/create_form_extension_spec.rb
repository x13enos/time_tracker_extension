require "rails_helper"

class DummyUsersCreateForm
  prepend TimeTrackerExtension::Users::CreateFormExtension

  def persist!
    user_attributes
  end

  def user_attributes
    { id: 1 }
  end

end

module TimeTrackerExtension
  module Users
    RSpec.describe CreateFormExtension do
      describe "user_attributes" do
        it "should add telegram token to the original user's attributes" do
          allow(SecureRandom).to receive(:hex) { '1111' }
          expect(DummyUsersCreateForm.new.persist!).to eq({
            id: 1,
            telegram_token: '1111'
          })
        end
      end
    end
  end
end
