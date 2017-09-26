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

    config.active_job.queue_adapter = :delayed_job

    # Time settings
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.time_zone = 'UTC'

    # Roles and Policies
    config.autoload_paths += %W(#{config.root}/app/policies #{config.root}/app/roles)

  end
end
