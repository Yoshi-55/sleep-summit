Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end
  root "home#index"

  get "dashboard", to: "dashboard#index"

  get "history", to: "history#index"

  get "profile", to: "profiles#show"

  # ⚠️render(freeプランはshell入れないので）ここからMVP用サンプルデータを投入するためのルート、使用後コメントアウトor削除する
  get "/seed_sample_data", to: "seeds#sample_data"



  resources :sleep_records, only: [ :create, :update ]
end
