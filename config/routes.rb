Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "home#index"

  get "dashboard", to: "dashboard#index"

  get "history", to: "history#index"

  get "profile", to: "profiles#show"

  resources :sleep_records, only: [ :create, :update ]
end
