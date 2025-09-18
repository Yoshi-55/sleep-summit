Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "sleep_records#index", as: :authenticated_root
  end
  root "home#index"

  resources :sleep_records, only: [:index, :create, :update]
end
