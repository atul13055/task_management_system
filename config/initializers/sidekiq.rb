redis_url = ENV.fetch('REDIS_URL') {
  Rails.env.production? ? raise("REDIS_URL is not set") : 'redis://localhost:6379/0'
}

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end
