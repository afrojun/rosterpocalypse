# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# Redirect to the canonical URL in production
use Rack::CanonicalHost, ENV['CANONICAL_HOST'], cache_control: 'max-age=3600604800' if ENV['CANONICAL_HOST']
run Rails.application
