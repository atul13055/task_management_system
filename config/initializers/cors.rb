Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Use different origins for different environments
    origins = if Rails.env.production?
                ENV.fetch('FRONTEND_PRODUCTION_URL', 'https://your-production-frontend.com')
              else
                ENV.fetch('FRONTEND_DEV_URL', 'http://localhost:3000')
              end

    origins origins

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
