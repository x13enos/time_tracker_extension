Rails.application.routes.draw do
  mount TimeTrackerExtension::Engine => "/time_tracker_extension"
end
