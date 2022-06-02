Rails.application.routes.draw do
  root 'home#index'
  post '/calendar', to: 'home#calendar', as: 'calendar'
  get '/mini_calendar', to: 'home#mini_calendar', as: 'mini_calendar'
  get '/cal/daily', to: 'home#daily', as: "calendar_daily"
  get '/cal/weekly', to: 'home#weekly', as: "calendar_weekly"
  get '/cal/monthly', to: 'home#monthly', as: "calendar_monthly"

  get '/sign_in', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/sign_out', to: 'sessions#destroy'

  resources :users, only: [:edit, :update] do
    collection do
      get 'suggest'
    end

    member do
      get 'profile'
      get 'card'
      get 'edit_tags'
      post 'add_watch_tag'
      post 'remove_watch_tag'
    end
  end

  resources :interviews do
    member do
      get 'card'
      get 'confirm'
    end

    collection do
      get '/search', to: 'interviews#search', as: 'search'
    end
  end

  resources :tags do
    collection do
      get 'suggest'
    end
  end

  resources :messages do
    resources :applyings, only: [:new, :create]

    collection do
      post '/query', to: 'messages#query', as: 'query'
    end
  end

  resources :applyings, only: [] do
    member do
      post 'close'
      post 'open'
    end

    resources :replies, only: [:new, :create] do
      collection do
        post 'previous'
      end
    end
  end
end
