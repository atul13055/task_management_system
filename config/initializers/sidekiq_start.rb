if Rails.env.production?
  Thread.new do
    require 'sidekiq/cli'
    Sidekiq::CLI.instance.run
  end
end
