Rails.application.routes.draw do
  root 'welcome#index'
  get 'welcome/index'
  get 'welcome', to: 'welcome#index'

  get 'about/index'
  get 'about', to: 'about#index'

  get 'credits/index'
  get 'credits', to: 'credits#index'

  resources :tournaments
  resources :heroes
  resources :games do
    resources :details, controller: 'game_details', shallow: true, only: [:new, :create, :edit, :update, :destroy]
    collection do
      post "bulk_destroy"
    end
  end
  resources :teams
  resources :players do
    collection do
      post "merge"
    end
  end
  resources :maps
  resources :rosters
  resources :leagues do
    member do
      post "join"
      post "leave"
    end
  end
  resources :private_leagues do
    member do
      post "join"
      post "leave"
    end
  end
  resources :public_leagues do
    member do
      post "join"
      post "leave"
    end
  end
  resources :managers, only: [:index, :show]

  devise_for :users, class_name: 'FormUser', controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  post 'replay_details', to: 'api/game_stats_ingestion#create'
end
