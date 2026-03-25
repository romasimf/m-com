Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "profiles#show", as: :authenticated_root
  end

  unauthenticated do
    root "home#index"
  end

  resource :profile, only: [:show]
  resources :posts, only: [:new, :create, :show, :destroy]
end