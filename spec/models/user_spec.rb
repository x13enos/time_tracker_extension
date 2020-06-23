require 'rails_helper'

RSpec.describe Workspace, type: :model do

  context "associations" do
    it { should have_many(:time_locking_periods)  }
  end

  describe "generate_telegram_token" do
    it "should add Telegram token to new user before creating" do
      user = build(:user, active_workspace: create(:workspace))
      expect(user.telegram_token).to be_nil
      allow(SecureRandom).to receive(:hex) { 'token' }
      user.save
      expect(User.last.telegram_token).to eq('token')
    end
  end

end
