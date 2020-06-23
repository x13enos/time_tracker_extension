TimeTrackerExtension::Engine.routes.draw do
  telegram_webhook TimeTrackerExtension::TelegramController

  namespace :v1 do
    resources :auth, only: :index
    resources :time_records, only: :index
    resources :time_locking_rules, except: [:new, :show, :edit]
    resources :time_locking_periods, only: [:update]
  end

end
