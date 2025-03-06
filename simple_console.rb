#!/usr/bin/env ruby
# frozen_string_literal: true

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('lib', __dir__))

# Load environment variables from .env file if available
begin
  require 'dotenv'
  Dotenv.load
  puts "Loaded environment variables from .env file"
rescue LoadError
  puts "dotenv gem not available, skipping .env loading"
end

# Try to load OpenSSL
begin
  require 'openssl'
  puts "OpenSSL is available: #{OpenSSL::OPENSSL_VERSION}"
rescue LoadError => e
  puts "Error loading OpenSSL: #{e.message}"
end

# Load the stax_payments library
begin
  require 'stax_payments'
  puts "Successfully loaded stax_payments library"

  # Create a client instance if credentials are available
  client = if ENV['STAX_API_KEY']
    puts "Initialized client with environment variables"
    StaxPayments::Client.new
  else
    puts "NOTE: No API credentials found in environment variables."
    puts "You'll need to initialize the client manually with:"
    puts "client = StaxPayments::Client.new(api_key: 'your_key', api_secret: 'your_secret')"
    nil
  end

  # Start an interactive Ruby session
  require 'irb'
  puts "\nStarting IRB session with 'client' variable initialized if credentials were available"
  puts "You can now interact with the Stax Payments API"
  IRB.start
rescue => e
  puts "Error loading stax_payments: #{e.message}"
  puts e.backtrace.join("\n")
end