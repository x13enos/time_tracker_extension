require 'rails_helper'

module TimeTrackerExtension
  RSpec.describe V1::TimeRecordsController, type: :controller do
    routes { TimeTrackerExtension::Engine.routes }
    login_user(:staff)

    describe "GET #index" do
      it "should call methods for searching blocked days" do
        expect(TimeTrackerExtension::BlockedDaysSearcher).to receive(:new).with(
          @current_user,
          @current_user.active_workspace_id,
          "29-10-2019".to_datetime
        ) { double(perform: []) }
        get :index, params: { assigned_date: "29-10-2019", format: :json }
      end

      it "should find and return blocked days" do
        allow(TimeTrackerExtension::BlockedDaysSearcher).to receive(:new) {
          double(perform: ["29-10-2019".to_date, "30-10-2019".to_date])
        }
        get :index, params: { assigned_date: "29-10-2019", format: :json }
        expect(response.body).to eq({
          time_records: [],
          blocked_days: ["29/10/2019", "30/10/2019"]
        }.to_json)
      end
    end
  end
end
