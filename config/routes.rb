Rails.application.routes.draw do
  devise_for :users
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "home#index"

  resources :sleep_records, only: [] do
    collection do
      post :start_sleep, to: "dashboard#start_sleep"
      post :wake_up,   to: "dashboard#wake_up"
    end
  end
end
