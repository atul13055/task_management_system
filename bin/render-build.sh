#!/bin/bash

# Exit on first error
set -e

echo "Installing dependencies..."
bundle install --deployment --without development test

echo "Running database migrations..."
bundle exec rake db:migrate RAILS_ENV=production

echo "Seeding the database..."
bundle exec rake db:seed RAILS_ENV=production || true

echo "Setting up permissions..."
chmod -R 777 log tmp/pids tmp/cache tmp/sockets

echo "Build process completed for the API."
