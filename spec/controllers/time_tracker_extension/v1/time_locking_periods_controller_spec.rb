require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::TimeLockingPeriodsController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }

    describe "PUT #update" do

      context "approve via email" do
        let!(:user) { create(:user) }
        let!(:workspace) { create(:workspace) }
        let!(:period) { create(:time_locking_period, user: user, workspace: workspace)  }
        let(:request_params) { {
          token: "22222222",
          workspace_id: workspace.id,
          id: period.id,
          format: :json
        } }

        context "user was found by decoded token" do
          before do
            allow(TokenCryptService).to receive(:decode).with("22222222") { user.email }
          end

          it "should try to search user by decoded email" do
            expect(User).to receive(:find_by).with({ email: user.email }) { user }
            put :update, params: request_params
          end

          it "should create approving form" do
            allow(User).to receive(:find_by) { user }
            allow(user).to receive_message_chain(:time_locking_periods, :where, :find) { period }
            expect(TimeTrackerExtension::PeriodApprover).to receive(:new).with(period) { double(perform: true) }
            put :update, params: request_params
          end

          it "should return 200 status" do
            allow(User).to receive(:find_by) { user }
            expect(TimeTrackerExtension::PeriodApprover).to receive(:new) { double(perform: true) }
            put :update, params: request_params
            expect(response.status).to eq(200)
          end

          it "should return 400 status if period wasn't approved" do
            allow(User).to receive(:find_by) { user }
            expect(TimeTrackerExtension::PeriodApprover).to receive(:new) { double(perform: false, period: period) }
            put :update, params: request_params
            expect(response.status).to eq(400)
          end

          it "should return error message if period wasn't approved" do
            allow(User).to receive(:find_by) { user }
            allow(user).to receive_message_chain(:time_locking_periods, :where, :find) { period  }
            expect(TimeTrackerExtension::PeriodApprover).to receive(:new) { double(perform: false, period: period) }
            period.errors.add(:base, "error")
            put :update, params: request_params
            expect(response.body).to eq({ errors: { base: ["error"] } }.to_json)
          end
        end

        it "should return error message if token was expired" do
          allow(TokenCryptService).to receive(:decode).with("22222222") { nil }
          put :update, params: request_params
          expect(response.body).to eq({ errors: { base: I18n.t("time_locking_periods.invalid_token") } }.to_json)
        end
      end

      context "approve via UI" do
        login_user(:staff)
        let!(:period) { create(:time_locking_period, approved: false, user: @current_user, workspace_id: @current_user.active_workspace_id)  }

        let(:request_params) { {
          id: period.id,
          format: :json
        } }

        before do
          cookies['token'] = '33333333'
          allow(TokenCryptService).to receive(:decode).with("33333333") { @current_user.email }
        end

        it "should try to search user by decoded email" do
          expect(User).to receive(:find_by).with({ email: @current_user.email }) { @current_user }
          put :update, params: request_params
        end

        it "should find period and approve it " do
          put :update, params: request_params
          expect(period.reload.approved).to be_truthy
        end

        it "should find period and approve it" do
          allow(User).to receive(:find_by) { @current_user }
          allow(@current_user).to receive_message_chain(:time_locking_periods, :where, :find) { period }
          approver = double(perform: true)
          expect(TimeTrackerExtension::PeriodApprover).to receive(:new).with(period) { approver }
          expect(approver).to receive(:perform)
          put :update, params: request_params
        end
      end
    end
  end
end
