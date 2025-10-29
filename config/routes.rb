Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "home#index"

  post  "sleep_records/start_wake"  => "sleep_records#start_wake",  as: :start_wake
  patch "sleep_records/finish_bed"  => "sleep_records#finish_bed",  as: :finish_bed

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "history",   to: "history#index",   as: :history

  get "profile",        to: "users#show",  as: :profile
  get "profile/edit",   to: "users#edit",  as: :edit_profile
  resource :profile, only: [ :update ], controller: "users"

  if Rails.env.production?
    get "/seed_sample_data", to: "seeds#sample_data"
  end

  # 編集画面用（index/history から編集へ）
  resources :sleep_records, only: [ :index, :show, :edit, :update ]
end
