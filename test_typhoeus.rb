#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'bundler/setup'
require 'typhoeus'

puts "Testing Typhoeus..."
puts "Typhoeus version: #{Typhoeus::VERSION}"

# Make a simple request to a public API
response = Typhoeus.get("https://httpbin.org/get")

puts "Response successful? #{response.success?}"
puts "Response code: #{response.code}"
puts "Response body: #{response.body[0..100]}..." # Show just the first 100 chars

puts "Typhoeus test completed successfully!" 