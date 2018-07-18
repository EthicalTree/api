redis_config = {
  url: 'redis://ethicaltree-redis-master:6379/0',
  password: Rails.application.secrets[:redis][:password]
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
