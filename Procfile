web: bundle exec puma -C config/puma.rb
client: sh -c 'rm app/assets/webpack/* || true && cd client && npm run build:production'
worker: bundle exec sidekiq -e production -C config/sidekiq.yml