Rails.application.routes.draw do
  root 'home#index'
  post '/calendar', to: 'home#calendar', as: 'calendar'
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
      get 'edit_tags'
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

  resources :tags

  resources :messages do
    member do
      get '/apply', to: 'messages#apply', as: 'apply'
      post '/apply', to: 'messages#submit_apply', as: 'submit_apply'
    end

    collection do
      post '/query', to: 'messages#query', as: 'query'
    end
  end
end
