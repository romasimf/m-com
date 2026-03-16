Rails.application.routes.draw do
  devise_for :users
  root "posts#index"
  get "/profile", to: "profiles#show", as: :profile
end
