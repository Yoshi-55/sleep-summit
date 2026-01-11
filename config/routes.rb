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

  resource :profile, only: [ :show, :edit, :update ], controller: "users"

  resources :sleep_records, only: [ :new, :create, :update, :edit, :destroy ] do
    collection do
      post :record_wake
    end
    member do
      patch :record_bed
    end
  end

  # Google Calendar
  resource :google_calendar_connection, only: [ :destroy ], path: "google_calendars/connection"
  resources :google_calendars, only: [ :index, :create, :update, :destroy ]

  # Pages
  get "terms", to: "pages#terms", as: :terms
  get "privacy", to: "pages#privacy", as: :privacy
  get "contact", to: "pages#contact", as: :contact
end
