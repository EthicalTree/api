require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EthicalTree
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :sidekiq

    # Caching
    redis_url = 'redis://ethicaltree-redis-master:6379/0'
    config.cache_store = :redis_cache_store, {
      url: redis_url,
      namespace: "ethicaltree_cache_#{Rails.env}",
      password: Rails.application.secrets[:redis][:password]
    }

    # Queue
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.perform_caching = false
    config.action_mailer.perform_deliveries = true

    # Time settings
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.time_zone = 'UTC'

    # Roles and Policies
    config.autoload_paths += %W(#{config.root}/app/policies #{config.root}/app/roles)
    config.autoload_paths += %W(#{config.root}/app/lib)

    # Automatically convert case
    config.middleware.use OliveBranch::Middleware
  end
end
