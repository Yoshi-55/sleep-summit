Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "home#index"

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "history", to: "history#index", as: :history

  get "profile", to: "users#show", as: :profile
  get "profile/edit", to: "users#edit", as: :edit_profile
  resource :profile, only: [ :update ], controller: "users"

  if Rails.env.production?
    get "/seed_sample_data", to: "seeds#sample_data"
  end


  resources :sleep_records, only: [ :new, :create, :update, :edit ]

  # Google Calendar
  resources :google_calendars, only: [ :index, :create, :update, :destroy ] do
    delete :disconnect, on: :collection
  end

  # Pages
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy
end
