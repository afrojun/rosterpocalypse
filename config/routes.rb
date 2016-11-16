Rails.application.routes.draw do
  resources :players
  devise_for :users
  get 'welcome/index'

  root 'welcome#index'
end
