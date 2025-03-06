# frozen_string_literal: true

require 'rubygems'
require 'json'
require 'typhoeus'
require 'awrence'
require 'plissken'
require 'base64'
require 'ostruct'

# Ensure Typhoeus is available in the global namespace
Typhoeus = ::Typhoeus unless defined?(Typhoeus)

require_relative 'stax_payments/version'
require_relative 'stax_payments/client'
require_relative 'stax_payments/stax_object_types'
require_relative 'stax_payments/stax_error'
