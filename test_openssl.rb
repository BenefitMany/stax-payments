#!/usr/bin/env ruby
# frozen_string_literal: true

begin
  require 'openssl'
  puts "OpenSSL is available!"
  puts "OpenSSL version: #{OpenSSL::OPENSSL_VERSION}"
  puts "OpenSSL library version: #{OpenSSL::OPENSSL_LIBRARY_VERSION}"
rescue LoadError => e
  puts "Error loading OpenSSL: #{e.message}"
  puts "You may need to install OpenSSL and rebuild Ruby."
end 