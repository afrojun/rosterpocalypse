Rails.application.routes.draw do
  root 'welcome#index'
  get 'welcome/index'
  get 'welcome', to: 'welcome#index'

  get 'about/index'
  get 'about', to: 'about#index'

  get 'credits/index'
  get 'credits', to: 'credits#index'

  resources :heroes
  resources :games do
    resources :details, controller: 'game_details', shallow: true
  end
  resources :teams
  resources :players
  resources :maps
  resources :rosters
  resources :managers, only: [:index, :show]


  devise_for :users, class_name: 'FormUser', controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  post 'replay_details', to: 'api/game_stats_ingestion#create'
end
