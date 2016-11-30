Rails.application.routes.draw do
  resources :maps
  root 'welcome#index'
  get 'welcome/index'
  get 'welcome', to: 'welcome#index'

  get 'about/index'
  get 'about', to: 'about#index'

  resources :heroes
  resources :games
  resources :teams
  resources :players

  devise_for :users

  post 'replay_details', to: 'api/game_stats_ingestion#create'
end
