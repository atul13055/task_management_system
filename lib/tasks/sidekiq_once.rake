namespace :sidekiq do
  desc "Run Sidekiq temporarily to process jobs"
  task run_once: :environment do
    puts "Starting Sidekiq for 60 seconds..."
    pid = spawn("bundle exec sidekiq -q default")
    sleep 60
    Process.kill("TERM", pid)
    puts "Stopped Sidekiq after 60 seconds."
  end
end
