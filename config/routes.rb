Rails.application.routes.draw do
  resources :rosters
  resources :managers
  root 'welcome#index'
  get 'welcome/index'
  get 'welcome', to: 'welcome#index'

  get 'about/index'
  get 'about', to: 'about#index'

  get 'credits/index'
  get 'credits', to: 'credits#index'

  resources :heroes
  resources :games
  resources :teams
  resources :players
  resources :maps

  devise_for :users

  post 'replay_details', to: 'api/game_stats_ingestion#create'
end
