Rails.application.routes.draw do
  resources :tags
  root 'home#index'
  get '/cal/daily', to: 'home#daily', as: "calendar_daily"
  get '/cal/weekly', to: 'home#weekly', as: "calendar_weekly"
  get '/cal/monthly', to: 'home#monthly', as: "calendar_monthly"

  get 'auth/github/callback', to: 'sessions#callback'
  get '/sign_out', to: 'sessions#destroy'

  resources :users, only: [:edit, :update] do
    collection do
      get 'suggest'
    end

    member do
      get 'profile'
    end
  end

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
