# frozen_string_literal: true

require 'test_helper'

module StaxPayments
  class TestPayments < Minitest::Test
    def setup
      @client = StaxPayments::Client.new(
        api_key: 'test_key',
        api_secret: 'test_secret',
        environment: 'sandbox'
      )
      @payment_method_id = '123456'
      @base_charge_params = {
        payment_method_id: @payment_method_id,
        total: 25.50,
        meta: {
          tax: 2.50,
          subtotal: 23.00,
          lineItems: [
            {
              item: 'Test Item',
              details: 'Test item details',
              quantity: 1,
              price: 23.00
            }
          ]
        }
      }
      @base_verify_params = {
        payment_method_id: @payment_method_id,
        total: 1.00,
        meta: {
          tax: 0,
          subtotal: 1.00
        }
      }
    end

    def test_charge_payment_method_with_required_params
      expected_response = {
        id: '987654',
        success: true,
        total: 25.50,
        type: 'sale',
        method: 'card',
        last_four: '1234',
        created_at: '2023-03-01T12:00:00Z',
        pre_auth: false
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/charge")
        .with(
          body: hash_including({
            payment_method_id: @payment_method_id,
            total: 25.50,
            meta: hash_including({
              tax: 2.50,
              subtotal: 23.00
            })
          }),
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key:test_secret',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = @client.charge_payment_method(@base_charge_params)
      
      assert_equal expected_response[:id], result.id
      assert_equal expected_response[:success], result.success
      assert_equal expected_response[:total], result.total
      assert_equal expected_response[:type], result.type
      assert_equal expected_response[:method], result.method
      assert_equal expected_response[:last_four], result.last_four
      assert_equal expected_response[:created_at], result.created_at
      assert_equal expected_response[:pre_auth], result.pre_auth
    end

    def test_charge_payment_method_with_all_params
      full_params = @base_charge_params.merge({
        pre_auth: true,
        currency: 'USD',
        idempotency_id: 'test-idempotency-123',
        channel: 'test-channel',
        funding: [
          {
            account_id: 'acct_123',
            amount: 25.50
          }
        ]
      })

      expected_response = {
        id: '987654',
        success: true,
        total: 25.50,
        type: 'auth',
        method: 'card',
        last_four: '1234',
        created_at: '2023-03-01T12:00:00Z',
        pre_auth: true,
        currency: 'USD',
        channel: 'test-channel'
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/charge")
        .with(
          body: hash_including({
            payment_method_id: @payment_method_id,
            total: 25.50,
            pre_auth: true,
            currency: 'USD',
            idempotency_id: 'test-idempotency-123',
            channel: 'test-channel',
            funding: [
              {
                account_id: 'acct_123',
                amount: 25.50
              }
            ]
          }),
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key:test_secret',
            'Content-Type' => 'application/json',
            'Idempotency-Key' => 'test-idempotency-123'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = @client.charge_payment_method(full_params)
      
      assert_equal expected_response[:id], result.id
      assert_equal expected_response[:success], result.success
      assert_equal expected_response[:total], result.total
      assert_equal expected_response[:type], result.type
      assert_equal expected_response[:method], result.method
      assert_equal expected_response[:pre_auth], result.pre_auth
      assert_equal expected_response[:currency], result.currency
      assert_equal expected_response[:channel], result.channel
    end

    def test_charge_payment_method_with_error
      error_response = {
        status: 'error',
        message: 'Invalid payment method ID',
        error_code: 'invalid_payment_method'
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/charge")
        .to_return(
          status: 400,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      error = assert_raises(StaxPayments::StaxError) do
        @client.charge_payment_method(@base_charge_params)
      end
      
      assert_equal 400, error.status_code
      assert_equal 'Invalid payment method ID', error.message
      assert_equal({ 'error_code' => 'invalid_payment_method' }, error.error_details)
    end

    def test_charge_payment_method_missing_required_params
      # Test missing payment_method_id
      invalid_params = @base_charge_params.dup
      invalid_params.delete(:payment_method_id)
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/payment_method_id is required/, error.message)
      
      # Test missing total
      invalid_params = @base_charge_params.dup
      invalid_params.delete(:total)
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/total is required/, error.message)
      
      # Test missing meta
      invalid_params = @base_charge_params.dup
      invalid_params.delete(:meta)
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/meta is required/, error.message)
    end

    def test_charge_payment_method_invalid_params
      # Test invalid total (not a number)
      invalid_params = @base_charge_params.dup
      invalid_params[:total] = 'not-a-number'
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/total must be a number/, error.message)
      
      # Test invalid pre_auth (not a boolean)
      invalid_params = @base_charge_params.dup
      invalid_params[:pre_auth] = 'not-a-boolean'
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/pre_auth must be a boolean/, error.message)
      
      # Test invalid currency
      invalid_params = @base_charge_params.dup
      invalid_params[:currency] = 'EUR'
      
      error = assert_raises(ArgumentError) do
        @client.charge_payment_method(invalid_params)
      end
      
      assert_match(/currency must be 'USD'/, error.message)
    end

    def test_verify_payment_method_with_default_params
      expected_response = {
        id: '987654',
        success: true,
        total: 1.00,
        type: 'pre_auth',
        method: 'card',
        last_four: '1234',
        created_at: '2023-03-01T12:00:00Z',
        pre_auth: true
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/verify")
        .with(
          body: hash_including({
            payment_method_id: @payment_method_id,
            total: 1.00,
            meta: hash_including({
              tax: 0,
              subtotal: 1.00
            }),
            pre_auth: true
          }),
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key:test_secret',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = @client.verify_payment_method(@base_verify_params)
      
      assert_instance_of StaxPayments::Transaction, result
      assert_equal expected_response[:id], result.id
      assert_equal expected_response[:success], result.success
      assert_equal expected_response[:total], result.total
      assert_equal expected_response[:type], result.type
      assert_equal expected_response[:method], result.method
      assert_equal expected_response[:last_four], result.last_four
      assert_equal expected_response[:created_at], result.created_at
      assert_equal expected_response[:pre_auth], result.pre_auth
    end

    def test_verify_payment_method_with_explicit_pre_auth_false
      params = @base_verify_params.merge(pre_auth: false)
      
      expected_response = {
        id: '987654',
        success: true,
        total: 1.00,
        type: 'sale',
        method: 'card',
        last_four: '1234',
        created_at: '2023-03-01T12:00:00Z',
        pre_auth: false
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/verify")
        .with(
          body: hash_including({
            payment_method_id: @payment_method_id,
            total: 1.00,
            meta: hash_including({
              tax: 0,
              subtotal: 1.00
            }),
            pre_auth: false
          }),
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key:test_secret',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      result = @client.verify_payment_method(params)
      
      assert_instance_of StaxPayments::Transaction, result
      assert_equal expected_response[:id], result.id
      assert_equal expected_response[:success], result.success
      assert_equal expected_response[:total], result.total
      assert_equal expected_response[:type], result.type
      assert_equal expected_response[:method], result.method
      assert_equal expected_response[:pre_auth], result.pre_auth
    end

    def test_verify_payment_method_with_error
      error_response = {
        status: 'error',
        message: 'Invalid payment method ID',
        error_code: 'invalid_payment_method'
      }

      stub_request(:post, "https://apisandbox.fattlabs.com/verify")
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      error = assert_raises(StaxPayments::StaxError) do
        @client.verify_payment_method(@base_verify_params)
      end
      
      assert_equal 422, error.status_code
      assert_equal 'Invalid payment method ID', error.message
      assert_equal({ 'error_code' => 'invalid_payment_method' }, error.error_details)
    end

    def test_verify_payment_method_missing_required_params
      # Test missing payment_method_id
      invalid_params = @base_verify_params.dup
      invalid_params.delete(:payment_method_id)
      
      error = assert_raises(ArgumentError) do
        @client.verify_payment_method(invalid_params)
      end
      
      assert_match(/payment_method_id is required/, error.message)
      
      # Test missing total
      invalid_params = @base_verify_params.dup
      invalid_params.delete(:total)
      
      error = assert_raises(ArgumentError) do
        @client.verify_payment_method(invalid_params)
      end
      
      assert_match(/total is required/, error.message)
      
      # Test missing meta
      invalid_params = @base_verify_params.dup
      invalid_params.delete(:meta)
      
      error = assert_raises(ArgumentError) do
        @client.verify_payment_method(invalid_params)
      end
      
      assert_match(/meta is required/, error.message)
    end

    def test_verify_payment_method_invalid_params
      # Test invalid total (not a number)
      invalid_params = @base_verify_params.dup
      invalid_params[:total] = 'not-a-number'
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.verify_payment_method(invalid_params)
      end
      assert_equal 'The total must be greater than 0', error.message
      
      # Test invalid pre_auth (not a boolean)
      invalid_params = @base_verify_params.dup
      invalid_params[:pre_auth] = 'not-a-boolean'
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.verify_payment_method(invalid_params)
      end
      assert_equal 'The pre_auth field must be a boolean value', error.message
    end

    def setup_credit_test
      @base_credit_params = {
        payment_method_id: 'pm_123456789',
        total: 1.00,
        meta: {
          memo: 'Refund for Subscription',
          subtotal: '1.00',
          tax: '0'
        }
      }
    end
    
    def test_credit_payment_method_with_required_params
      setup_credit_test
      
      expected_response = {
        id: 'txn_123456789',
        type: 'credit',
        success: true,
        total: 1.00,
        method: 'card',
        pre_auth: false,
        last_four: '1111',
        meta: {
          memo: 'Refund for Subscription',
          subtotal: '1.00',
          tax: '0'
        },
        customer: {
          id: 'cus_123456789',
          firstname: 'John',
          lastname: 'Doe'
        },
        payment_method: {
          id: 'pm_123456789',
          card_last_four: '1111'
        }
      }
      
      stub_request(:post, "https://apisandbox.fattlabs.com/creditRequest")
        .with(
          body: @base_credit_params,
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.credit_payment_method(@base_credit_params)
      
      assert_equal 'txn_123456789', result.id
      assert_equal 'credit', result.type
      assert_equal true, result.success
      assert_equal 1.00, result.total
      assert_equal 'card', result.method
      assert_equal false, result.pre_auth
      assert_equal '1111', result.last_four
      assert_equal 'Refund for Subscription', result.meta[:memo]
      assert_equal 'John', result.customer[:firstname]
      assert_equal 'Doe', result.customer[:lastname]
      assert_equal 'pm_123456789', result.payment_method[:id]
      assert_equal '1111', result.payment_method[:card_last_four]
    end
    
    def test_credit_payment_method_with_error
      setup_credit_test
      
      error_response = {
        payment_method_id: [
          "The selected payment method id is invalid."
        ]
      }
      
      stub_request(:post, "https://apisandbox.fattlabs.com/creditRequest")
        .with(
          body: @base_credit_params,
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.credit_payment_method(@base_credit_params)
      
      assert_instance_of StaxPayments::StaxError, result
      assert_equal 422, result.status_code
      assert_equal error_response, result.error_details
    end
    
    def test_credit_payment_method_missing_required_params
      setup_credit_test
      
      # Test missing payment_method_id
      invalid_params = @base_credit_params.dup
      invalid_params.delete(:payment_method_id)
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The payment_method_id field is required', error.message
      
      # Test missing total
      invalid_params = @base_credit_params.dup
      invalid_params.delete(:total)
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The total field is required', error.message
      
      # Test missing meta
      invalid_params = @base_credit_params.dup
      invalid_params.delete(:meta)
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The meta field is required', error.message
    end
    
    def test_credit_payment_method_invalid_params
      setup_credit_test
      
      # Test invalid total (not a number)
      invalid_params = @base_credit_params.dup
      invalid_params[:total] = 'not-a-number'
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The total must be greater than 0', error.message
      
      # Test invalid total (zero)
      invalid_params = @base_credit_params.dup
      invalid_params[:total] = 0
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The total must be greater than 0', error.message
      
      # Test invalid total (negative)
      invalid_params = @base_credit_params.dup
      invalid_params[:total] = -1.00
      
      error = assert_raises(StaxPayments::StaxError) do
        @client.credit_payment_method(invalid_params)
      end
      assert_equal 'The total must be greater than 0', error.message
    end
  end
end 