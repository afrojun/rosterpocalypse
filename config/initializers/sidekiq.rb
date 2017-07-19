if Rails.env.production?

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'], size: 2 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDISCLOUD_URL'], size: 22 }

    database_url = ENV['DATABASE_URL']

    raise 'Unable to determine the Database URL. Bailing out.' unless database_url

    Rails.application.config.after_initialize do
      Rails.logger.info("DB Connection Pool size for Sidekiq Server before disconnect is: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
      ActiveRecord::Base.connection_pool.disconnect!

      ActiveSupport.on_load(:active_record) do
        reaping_frequency = ENV['DATABASE_REAP_FREQ'] || 10 # seconds
        pool = ENV['WORKER_DB_POOL_SIZE'] || Sidekiq.options[:concurrency]
        ENV['DATABASE_URL'] = "#{database_url}?pool=#{pool}&reaping_frequency=#{reaping_frequency}"

        ActiveRecord::Base.establish_connection

        Rails.logger.info("DB Connection Pool size for Sidekiq Server is now: #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}")
      end
    end
  end

end
