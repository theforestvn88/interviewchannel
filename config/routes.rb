Rails.application.routes.draw do
  root 'home#index'

  get 'auth/github/callback', to: 'sessions#callback'
  get '/sign_out', to: 'sessions#destroy'

  resources :interviews do
    member do
      get 'room'
    end
  end
end
