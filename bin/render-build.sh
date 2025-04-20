#!/bin/bash

# Exit on first error
set -e

# Install dependencies
echo "Installing dependencies..."
bundle install --deployment --without development test

# Run database migrations
echo "Running database migrations..."
bundle exec rake db:migrate RAILS_ENV=production

# Precompile assets (skip if your API doesn't use assets)
echo "Precompiling assets (skip if API-only)..."
bundle exec rake assets:precompile RAILS_ENV=production || true

# Clean up old assets (skip if API-only)
echo "Cleaning up old assets..."
bundle exec rake assets:clean RAILS_ENV=production || true

# Preload the Rails environment (optional for pre-seeding)
echo "Preloading the Rails environment..."
bundle exec rake db:seed RAILS_ENV=production || true

# Set up Sidekiq (if you're using background jobs)
echo "Setting up Sidekiq..."
bundle exec sidekiq -d # or any specific sidekiq command needed

# Ensure logs and temp directories are writable
echo "Setting up permissions..."
chmod -R 777 log tmp/pids tmp/cache tmp/sockets

# Any additional production configuration steps
# Example: setting up API key or JWT secret in environment variables
echo "Setting up environment variables..."
# For example, set the JWT secret key if not already set:
# export JWT_SECRET_KEY=your_secret_key_here

# Display completion message
echo "Build process completed for the API."
