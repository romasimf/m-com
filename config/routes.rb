Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  devise_for :users, controllers: { registrations: "users/registrations" }

  root "home#index"

  resource :profile, only: [:show]

  get "/profiles/:id", to: "profiles#show", as: :user_profile, constraints: { id: /\d+/ }

  resources :users, only: [] do
    resource :follow, only: [:create, :destroy]
  end

  get "/messages", to: "conversations#index", as: :messages
  post "/messages", to: "conversations#create"
  get "/messages/:id", to: "conversations#show", as: :conversation
  post "/messages/:conversation_id/send", to: "messages#create", as: :conversation_messages

  get "/notifications", to: "notifications#index", as: :notifications
  get "/settings", to: "pages#settings", as: :settings

  resources :posts, only: [:new, :create, :show, :edit, :update, :destroy] do
    resource :like, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end
end