Rails.application.routes.draw do
  root 'welcome#index'
  get 'welcome/index'
  get 'welcome', to: 'welcome#index'

  get 'about', to: 'about#about'
  get 'credits', to: 'about#credits'
  get 'privacy', to: 'about#privacy'
  get 'terms', to: 'about#terms'

  resources :heroes
  resources :maps
  resources :tournaments
  resources :matches

  resources :gameweeks, only: %i[index show]

  resources :rosters, except: %i[new create edit] do
    member do
      get "manage"
      get "details"
      get "players"
    end
  end

  resources :games do
    resources :details, controller: 'game_details', shallow: true, only: %i[new create edit update destroy]
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

  resources :managers, only: %i[index show update] do
    member do
      post "subscribe"
      post "unsubscribe"
      post "reactivate_subscription"
      put "update_payment_details"
      put "remove_payment_source"
    end
  end

  devise_for :users, class_name: 'FormUser', controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations', sessions: 'sessions' }

  post 'replay_details', to: 'api/game_stats_ingestion#create'

  get '/.well-known/acme-challenge/:id' => 'welcome#letsencrypt'

  mount StripeEvent::Engine, at: '/stripe_webhooks'

  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
