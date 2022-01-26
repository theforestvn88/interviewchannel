Rails.application.routes.draw do
  resources :interviews do
    member do
      get 'room'
    end
  end
end
