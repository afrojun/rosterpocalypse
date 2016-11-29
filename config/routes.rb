Rails.application.routes.draw do
  resources :heroes
  resources :games
  resources :teams
  resources :players
  devise_for :users
  get 'welcome/index'

  root 'welcome#index'

  post 'replay_details', to: 'api/game_stats_ingestion#create'
end
