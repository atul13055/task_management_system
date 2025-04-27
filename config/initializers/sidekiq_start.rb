if Rails.env.production?
  Thread.new do
    system("bundle exec sidekiq -C config/sidekiq.yml")
  end
end
