Rails.application.routes.draw do
  mount TimeTrackerExtension::Engine => "/"
end
