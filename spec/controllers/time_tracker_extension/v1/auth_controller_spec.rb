require 'rails_helper'

module TimeTrackerExtension

  RSpec.describe V1::AuthController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }

    let!(:user) { create(:user, password: '11111111') }

    describe "get #index" do
      context "user was authorized" do
        login_staff

        let!(:period) { create(:time_locking_period,
          user: @current_user,
          approved: false,
          workspace_id: @current_user.active_workspace_id,
          beginning_of_period: Date.today - 7.days,
          end_of_period: Date.today - 1.days,
        ) }

        let!(:period1) { create(:time_locking_period,
          user: @current_user,
          approved: false,
          workspace_id: @current_user.active_workspace_id,
          beginning_of_period: Date.today - 7.days,
          end_of_period: Date.today,
        ) }

        let!(:period2) { create(:time_locking_period,
          user: @current_user,
          approved: false,
          workspace_id: create(:workspace).id,
          beginning_of_period: Date.today - 7.days,
          end_of_period: Date.today - 1.days,
        ) }

        let!(:period3) { create(:time_locking_period,
          user: @current_user,
          approved: true,
          workspace_id: @current_user.active_workspace_id,
          beginning_of_period: Date.today - 7.days,
          end_of_period: Date.today - 1.days,
        ) }


        it "should return user's info and unapproved periods" do
          get :index, { format: :json }
          expect(response.body).to eq({
            id: @current_user.id,
            email: @current_user.email,
            name: @current_user.name,
            role: @current_user.role,
            locale: @current_user.locale,
            active_workspace_id: @current_user.active_workspace_id,
            unapproved_periods: [{
              id: period.id,
              from: period.beginning_of_period.strftime("%d/%m/%Y"),
              to: period.end_of_period.strftime("%d/%m/%Y")
            }]
          }.to_json)
        end
      end

      context "user was not authorized" do
        it "should return error message" do
          get :index, { format: :json }
          expect(response.body).to eq({ error: I18n.t("auth.errors.unathorized") }.to_json)
        end

        it "should return 401 status" do
          get :index, { format: :json }
          expect(response.status).to eq(401)
        end
      end
    end
  end

end
