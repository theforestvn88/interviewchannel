Rails.application.routes.draw do
  root 'home#index'
  get '/cal/daily', to: 'home#daily', as: "calendar_daily"
  get '/cal/weekly', to: 'home#weekly', as: "calendar_weekly"
  get '/cal/monthly', to: 'home#monthly', as: "calendar_monthly"

  get 'auth/github/callback', to: 'sessions#callback'
  get '/sign_out', to: 'sessions#destroy'
  get 'user/suggest', to: 'users#suggest', as: 'suggest_user'

  resources :interviews do
    member do
      get 'room'
      get 'card'
      get 'confirm'
    end

    collection do
      get '/search', to: 'interviews#search', as: 'search'
    end
  end
end
