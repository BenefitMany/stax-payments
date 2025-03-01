# frozen_string_literal: true

require_relative 'client/customers'
require_relative 'client/payments'
require_relative 'client/transactions'
require_relative 'client/cards'
require_relative 'client/bank_accounts'
require_relative 'client/invoices'
require_relative 'client/subscriptions'
require_relative 'client/plans'
require_relative 'client/refunds'
require_relative 'client/webhooks'

require_relative 'model/stax_model'
require_relative 'model/customer'
require_relative 'model/payment'
require_relative 'model/transaction'
require_relative 'model/card'
require_relative 'model/bank_account'
require_relative 'model/invoice'
require_relative 'model/subscription'
require_relative 'model/plan'
require_relative 'model/refund'
require_relative 'model/webhook'

module StaxPayments
  class Client
    include StaxPayments::Client::Customers
    include StaxPayments::Client::Payments
    include StaxPayments::Client::Transactions
    include StaxPayments::Client::Cards
    include StaxPayments::Client::BankAccounts
    include StaxPayments::Client::Invoices
    include StaxPayments::Client::Subscriptions
    include StaxPayments::Client::Plans
    include StaxPayments::Client::Refunds
    include StaxPayments::Client::Webhooks

    API_BASE_URL = 'https://api.staxpayments.com/'.freeze

    def initialize(auth = nil)
      @auth = auth || load_from_environment

      if @auth.nil?
        raise StaxError, 'API authentication incomplete! You need the API key and API secret.'
      end
    end

    private

    def load_from_environment
      return if ENV['STAX_API_KEY'].nil? || ENV['STAX_API_SECRET'].nil?

      {
        api_key: ENV['STAX_API_KEY'],
        api_secret: ENV['STAX_API_SECRET']
      }
    end

    def process_file(file_path, url_path, params)
      request_params = {
        method: :post,
        params: params.to_camelback_keys,
        headers: {
          "Content-Type" => "multipart/form-data",
          'Authorization' => "Basic #{stax_basic_auth}"
        },
        body: { file: ::File.open(file_path) }
      }

      proxy = @auth[:proxy] || ENV['PROXY']
      request_params[:proxy] = proxy unless proxy.nil?

      response = Typhoeus::Request.new(
        "#{API_BASE_URL}#{url_path}",
        request_params
      ).run
      return StaxError.new(response) unless response.success?

      process_stax_response(response.body)
    end

    def process_stax_response(response_body)
      JSON.parse(response_body, symbolize_names: true).to_snake_keys
    rescue
      response_body
    end

    def process_request(request_type, url_path, options = {})
      options_params = options[:params] || {}
      request_params = {
        method: request_type,
        params: options_params.to_camelback_keys,
        headers: stax_auth_headers,
        body: options[:body]&.to_json
      }

      proxy = @auth[:proxy] || ENV['PROXY']
      request_params[:proxy] = proxy unless proxy.nil?

      response = Typhoeus::Request.new(
        "#{API_BASE_URL}#{url_path}",
        request_params
      ).run
      return StaxError.new(response) unless response.success?

      process_stax_response(response.body)
    end

    def stax_auth_headers
      {
        'Content-Type' => 'application/json',
        'charset' => 'utf-8',
        'Authorization' => "Basic #{stax_basic_auth}"
      }
    end

    def stax_basic_auth
      Base64.strict_encode64("#{@auth[:api_key]}:#{@auth[:api_secret]}")
    end
  end
end
