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
  resources :maps
  resources :managers, only: [:index, :show]

  resources :rosters, except: [:edit] do
    member do
      get "manage"
      get "status"
    end
  end

  resources :games do
    resources :details, controller: 'game_details', shallow: true, only: [:new, :create, :edit, :update, :destroy]
    collection do
      post "bulk_destroy"
    end
    member do
      post "swap_teams"
    end
  end

  resources :teams do
    collection do
      post "merge"
    end
    member do
      post "toggle_active"
    end
  end

  resources :players do
    collection do
      post "merge"
    end
  end

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

  devise_for :users, class_name: 'FormUser', controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  post 'replay_details', to: 'api/game_stats_ingestion#create'

  get '/.well-known/acme-challenge/:id' => 'welcome#letsencrypt'
end
