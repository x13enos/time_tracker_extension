TimeTrackerExtension::Engine.routes.draw do

  namespace :v1 do
    resources :time_locking_rules, except: [:new, :show, :edit]
    resources :time_locking_periods, only: [:update]
  end

end
