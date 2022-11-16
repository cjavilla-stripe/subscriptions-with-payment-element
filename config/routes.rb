Rails.application.routes.draw do
  get 'subscriptions/new'
  get 'subscriptions/index'
  get 'dashboards/show'
  devise_for :users

  resource :pricing, only: [:show]
  resource :dashboard, only: [:show]
  resources :webhooks, only: [:create]
  resources :subscriptions, only: [:new, :index]

  root 'pages#root'
end
