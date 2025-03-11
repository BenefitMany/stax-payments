# frozen_string_literal: true

require 'test_helper'

module StaxPayments
  class TestPaymentMethods < Minitest::Test
    def setup
      @client = StaxPayments::Client.new(
        api_key: 'test_key'
      )
      
      # Sample payment method data for testing
      @payment_method_data = {
        id: '7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7',
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        merchant_id: '85c58c65-4da7-4f99-acb0-afa885874572',
        user_id: 'hosted-payments',
        nickname: 'VISA: Bob Smithers (ending in: 1111)',
        has_cvv: 0,
        is_default: 0,
        method: 'card',
        meta: {
          card_display: '484718',
          routing_display: nil,
          account_display: nil,
          eligible_for_card_updater: true,
          storage_state: 'cached',
          fingerprint: '888999888777888999988',
          errors: [],
          prepaid: nil
        },
        bin_type: 'DEBIT',
        person_name: 'Bob Smithers',
        card_type: 'visa',
        card_last_four: '1111',
        card_exp: '032022',
        bank_name: nil,
        bank_type: nil,
        bank_holder_type: nil,
        address_1: nil,
        address_2: nil,
        address_city: nil,
        address_state: nil,
        address_zip: '999999',
        address_country: nil,
        purged_at: nil,
        deleted_at: nil,
        created_at: '2018-08-03 17:59:10',
        updated_at: '2018-08-03 17:59:10',
        card_exp_datetime: '2022-03-31 23:59:59',
        is_usable_in_vt: true,
        is_tokenized: true,
        au_last_event: nil,
        au_last_event_at: nil
      }
    end
    
    def test_payment_methods
      expected_response = {
        current_page: 1,
        data: [@payment_method_data],
        first_page_url: 'https://apiprod.fattlabs.com/payment-method?page=1',
        from: 1,
        last_page: 1,
        last_page_url: 'https://apiprod.fattlabs.com/payment-method?page=1',
        next_page_url: nil,
        path: 'https://apiprod.fattlabs.com/payment-method',
        per_page: '10',
        prev_page_url: nil,
        to: 1,
        total: 1
      }
      
      stub_request(:get, 'https://apiprod.fattlabs.com/payment-method')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.payment_methods
      
      assert_equal 1, result[:pagination][:total]
      assert_equal 1, result[:payment_methods].size
      
      payment_method = result[:payment_methods].first
      assert_instance_of StaxPayments::PaymentMethod, payment_method
      assert_equal '7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7', payment_method.id
      assert_equal 'VISA: Bob Smithers (ending in: 1111)', payment_method.nickname
      assert_equal 'card', payment_method.method
      assert_equal 'visa', payment_method.card_type
      assert_equal '1111', payment_method.card_last_four
    end
    
    def test_payment_methods_with_filtering
      args = {
        per_page: 50,
        au_last_event: 'ReplacePaymentMethod',
        au_last_event_start_at: '2023-01-01 00:00:00'
      }
      
      expected_response = {
        current_page: 1,
        data: [@payment_method_data],
        first_page_url: 'https://apiprod.fattlabs.com/payment-method?page=1',
        from: 1,
        last_page: 1,
        last_page_url: 'https://apiprod.fattlabs.com/payment-method?page=1',
        next_page_url: nil,
        path: 'https://apiprod.fattlabs.com/payment-method',
        per_page: '50',
        prev_page_url: nil,
        to: 1,
        total: 1
      }
      
      stub_request(:get, 'https://apiprod.fattlabs.com/payment-method')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          query: {
            perPage: 50,
            auLastEvent: 'ReplacePaymentMethod',
            auLastEventStartAt: '2023-01-01 00:00:00'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.payment_methods(args)
      
      assert_equal 1, result[:pagination][:total]
      assert_equal 1, result[:payment_methods].size
    end
    
    def test_payment_methods_with_invalid_per_page
      args = { per_page: 201 }
      
      error = assert_raises(StaxError) do
        @client.payment_methods(args)
      end
      
      assert_equal 'per_page must be between 1 and 200', error.message
    end
    
    def test_payment_methods_with_invalid_au_last_event
      args = { au_last_event: 'InvalidEvent' }
      
      error = assert_raises(StaxError) do
        @client.payment_methods(args)
      end
      
      assert_equal 'au_last_event must be one of: ReplacePaymentMethod, ContactCardHolder, ClosePaymentMethod', error.message
    end
    
    def test_payment_methods_with_invalid_date_format
      args = { au_last_event_start_at: '2023-01-01' }
      
      error = assert_raises(StaxError) do
        @client.payment_methods(args)
      end
      
      assert_equal 'au_last_event_start_at must be in the format: yyyy-mm-dd hh:mm:ss', error.message
    end
    
    def test_payment_methods_with_invalid_status
      args = { status: 'invalid' }
      
      error = assert_raises(StaxError) do
        @client.payment_methods(args)
      end
      
      assert_equal 'status must be one of: all, deleted', error.message
    end
    
    def test_payment_method
      stub_request(:get, 'https://apiprod.fattlabs.com/payment-method/7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: @payment_method_data.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      payment_method = @client.payment_method('7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7')
      
      assert_instance_of StaxPayments::PaymentMethod, payment_method
      assert_equal '7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7', payment_method.id
      assert_equal 'VISA: Bob Smithers (ending in: 1111)', payment_method.nickname
      assert_equal 'card', payment_method.method
      assert_equal 'visa', payment_method.card_type
      assert_equal '1111', payment_method.card_last_four
      
      # Test new fields
      assert_equal 'DEBIT', payment_method.bin_type
      assert payment_method.debit?
      assert_equal '484718', payment_method.card_display
      assert_equal true, payment_method.eligible_for_card_updater?
      assert_equal 'cached', payment_method.storage_state
      assert_equal '888999888777888999988', payment_method.fingerprint
    end
    
    def test_payment_method_not_found
      stub_request(:get, 'https://apiprod.fattlabs.com/payment-method/invalid_id')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 404,
          body: { error: 'Payment method not found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.payment_method('invalid_id')
      
      assert_instance_of StaxError, result
      assert_match(/Payment method not found/, result.message)
    end
    
    def test_customer_payment_methods
      customer_id = '35e4cfa9-d87e-45fc-84da-a6bdce2c3330'
      
      expected_response = [
        @payment_method_data,
        @payment_method_data.merge(
          id: '403e043d-2971-4062-adc7-7e64f7882786',
          nickname: 'personal savings, BANK INC (ending in: 3210)',
          is_default: 1,
          method: 'bank',
          person_name: 'Bob Smith',
          card_type: nil,
          card_last_four: '3210',
          card_exp: nil,
          bank_name: 'Bank INC',
          bank_type: 'savings',
          bank_holder_type: 'personal',
          created_at: '2018-08-02 21:06:04',
          updated_at: '2018-08-02 21:06:04',
          card_exp_datetime: []
        )
      ]
      
      stub_request(:get, "https://apiprod.fattlabs.com/customer/#{customer_id}/payment-method")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      payment_methods = @client.customer_payment_methods(customer_id)
      
      assert_equal 2, payment_methods.size
      assert_instance_of StaxPayments::PaymentMethod, payment_methods.first
      assert_equal '7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7', payment_methods.first.id
      assert_equal '403e043d-2971-4062-adc7-7e64f7882786', payment_methods.last.id
      assert_equal 'bank', payment_methods.last.method
      assert_equal 'Bank INC', payment_methods.last.bank_name
    end
    
    def test_customer_payment_methods_not_found
      customer_id = 'invalid_id'
      
      error_response = {
        id: [
          "The selected id is invalid."
        ]
      }
      
      stub_request(:get, "https://apiprod.fattlabs.com/customer/#{customer_id}/payment-method")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.customer_payment_methods(customer_id)
      
      assert_instance_of StaxPayments::StaxError, result
      assert_equal 422, result.status_code
      assert_equal error_response, result.error_details
    end
    
    def test_delete_payment_method
      payment_method_id = '7e3a83ea-6770-41f7-9b28-7ea1a3ae33e7'
      
      expected_response = {
        id: payment_method_id,
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        merchant_id: '85c58c65-4da7-4f99-acb0-afa885874572',
        user_id: 'hosted-payments',
        nickname: 'VISA: Bob Smithers (ending in: 1111)',
        has_cvv: 0,
        is_default: 0,
        method: 'card',
        person_name: 'Bob Smithers',
        card_type: 'visa',
        card_last_four: '1111',
        card_exp: '032022',
        bank_name: nil,
        bank_type: nil,
        bank_holder_type: nil,
        address_1: nil,
        address_2: nil,
        address_city: nil,
        address_state: nil,
        address_zip: '999999',
        address_country: nil,
        purged_at: nil,
        deleted_at: '2023-01-01 12:00:00',
        created_at: '2018-08-03 17:59:10',
        updated_at: '2018-08-03 17:59:10',
        card_exp_datetime: '2022-03-31 23:59:59'
      }
      
      stub_request(:delete, "https://apiprod.fattlabs.com/payment-method/#{payment_method_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.delete_payment_method(payment_method_id)
      
      assert_instance_of StaxPayments::PaymentMethod, result
      assert_equal payment_method_id, result.id
      assert_equal '2023-01-01 12:00:00', result.deleted_at
      assert result.deleted?
    end
    
    def test_delete_payment_method_failure
      payment_method_id = 'invalid_id'
      
      stub_request(:delete, "https://apiprod.fattlabs.com/payment-method/#{payment_method_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 404,
          body: { error: 'Payment method not found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.delete_payment_method(payment_method_id)
      
      assert_instance_of StaxError, result
    end
    
    def test_create_payment_method_card
      card_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      expected_response = {
        id: '8041a7d7-d1d6-4ad0-ad8f-9fa8d2fbb845',
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        merchant_id: '160fb93e-996b-4239-8ff0-1bb3d5ce8313',
        user_id: '8f5f7d73-d53c-47c6-8880-6da0de8d9a10',
        method: 'card',
        card_type: 'visa',
        card_exp: '042027',
        has_cvv: true,
        address_1: nil,
        address_2: nil,
        address_city: nil,
        address_state: nil,
        address_zip: nil,
        address_country: nil,
        bank_name: nil,
        bank_type: nil,
        bank_holder_type: nil,
        is_default: 0,
        person_name: 'Steven Smith',
        meta: nil,
        card_last_four: '1111',
        nickname: 'VISA: Steven Smith (ending in: 1111)',
        updated_at: '2020-06-29 14:30:29',
        created_at: '2020-06-29 14:30:29',
        card_exp_datetime: '2027-04-30 23:59:59',
        is_usable_in_vt: true,
        is_tokenized: true
      }
      
      stub_request(:post, 'https://apiprod.fattlabs.com/payment-method')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: card_params.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      payment_method = @client.create_payment_method(card_params)
      
      assert_instance_of StaxPayments::PaymentMethod, payment_method
      assert_equal '8041a7d7-d1d6-4ad0-ad8f-9fa8d2fbb845', payment_method.id
      assert_equal '35e4cfa9-d87e-45fc-84da-a6bdce2c3330', payment_method.customer_id
      assert_equal 'card', payment_method.method
      assert_equal 'visa', payment_method.card_type
      assert_equal '1111', payment_method.card_last_four
      assert_equal 'Steven Smith', payment_method.person_name
      assert_equal '042027', payment_method.card_exp
      assert_equal true, payment_method.has_cvv?
    end
    
    def test_create_payment_method_bank
      bank_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'checking',
        bank_holder_type: 'personal'
      }
      
      expected_response = {
        id: '8041a7d7-d1d6-4ad0-ad8f-9fa8d2fbb845',
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        merchant_id: '160fb93e-996b-4239-8ff0-1bb3d5ce8313',
        user_id: '8f5f7d73-d53c-47c6-8880-6da0de8d9a10',
        method: 'bank',
        card_type: nil,
        card_exp: nil,
        has_cvv: false,
        address_1: nil,
        address_2: nil,
        address_city: nil,
        address_state: nil,
        address_zip: nil,
        address_country: nil,
        bank_name: 'Test Bank',
        bank_type: 'checking',
        bank_holder_type: 'personal',
        is_default: 0,
        person_name: 'Steven Smith',
        meta: nil,
        card_last_four: '6789',
        nickname: 'personal checking, Test Bank (ending in: 6789)',
        updated_at: '2020-06-29 14:30:29',
        created_at: '2020-06-29 14:30:29',
        card_exp_datetime: nil,
        is_usable_in_vt: true,
        is_tokenized: true
      }
      
      stub_request(:post, 'https://apiprod.fattlabs.com/payment-method')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: bank_params.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      payment_method = @client.create_payment_method(bank_params)
      
      assert_instance_of StaxPayments::PaymentMethod, payment_method
      assert_equal '8041a7d7-d1d6-4ad0-ad8f-9fa8d2fbb845', payment_method.id
      assert_equal '35e4cfa9-d87e-45fc-84da-a6bdce2c3330', payment_method.customer_id
      assert_equal 'bank', payment_method.method
      assert_equal 'Test Bank', payment_method.bank_name
      assert_equal 'checking', payment_method.bank_type
      assert_equal 'personal', payment_method.bank_holder_type
      assert_equal '6789', payment_method.card_last_four
    end
    
    def test_create_payment_method_with_error
      card_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error_response = {
        tokenization_error: [
          [
            "Number can't be blank",
            "Card type is invalid",
            "First name can't be blank",
            "Last name can't be blank",
            "could not reach tokenization service"
          ]
        ]
      }
      
      stub_request(:post, 'https://apiprod.fattlabs.com/payment-method')
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: card_params.to_json
        )
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.create_payment_method(card_params)
      
      assert_instance_of StaxError, result
      assert_equal 422, result.status_code
      assert_equal error_response, result.error_details
    end
    
    def test_create_payment_method_missing_required_params
      # Test missing customer_id
      invalid_params = {
        method: 'card',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The customer_id field is required', error.message
      
      # Test missing method
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The method field is required', error.message
      
      # Test invalid method
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'invalid',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal "The method must be 'card' or 'bank'", error.message
      
      # Test missing person_name
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The person_name field is required', error.message
      
      # Test invalid person_name format
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The person_name must include first and last name separated by a space', error.message
    end
    
    def test_create_payment_method_card_missing_required_params
      # Test missing card_number
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven Smith',
        card_cvv: '123',
        card_exp: '0427'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The card_number field is required for card payment methods', error.message
      
      # Test missing card_exp
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The card_exp field is required for card payment methods', error.message
      
      # Test invalid card_exp format
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'card',
        person_name: 'Steven Smith',
        card_number: '4111111111111111',
        card_cvv: '123',
        card_exp: '04/27'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The card_exp must be 4 digits (e.g., "0427" for April 2027)', error.message
    end
    
    def test_create_payment_method_bank_missing_required_params
      # Test missing bank_account
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'checking',
        bank_holder_type: 'personal'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The bank_account field is required for bank payment methods', error.message
      
      # Test missing bank_routing
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'checking',
        bank_holder_type: 'personal'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The bank_routing field is required for bank payment methods', error.message
      
      # Test missing bank_name
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_type: 'checking',
        bank_holder_type: 'personal'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The bank_name field is required for bank payment methods', error.message
      
      # Test missing bank_type
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_holder_type: 'personal'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The bank_type field is required for bank payment methods', error.message
      
      # Test invalid bank_type
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'invalid',
        bank_holder_type: 'personal'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal "The bank_type must be 'checking' or 'savings'", error.message
      
      # Test missing bank_holder_type
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'checking'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal 'The bank_holder_type field is required for bank payment methods', error.message
      
      # Test invalid bank_holder_type
      invalid_params = {
        customer_id: '35e4cfa9-d87e-45fc-84da-a6bdce2c3330',
        method: 'bank',
        person_name: 'Steven Smith',
        bank_account: '123456789',
        bank_routing: '123456789',
        bank_name: 'Test Bank',
        bank_type: 'checking',
        bank_holder_type: 'invalid'
      }
      
      error = assert_raises(StaxError) do
        @client.create_payment_method(invalid_params)
      end
      
      assert_equal "The bank_holder_type must be 'personal' or 'business'", error.message
    end
    
    def test_update_payment_method
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      update_params = {
        is_default: 1,
        person_name: 'Carl Junior Sr.',
        card_type: 'visa',
        card_last_four: '1111',
        card_exp: '032020',
        address_zip: '32944',
        address_country: 'USA'
      }
      
      expected_response = {
        id: payment_method_id,
        customer_id: 'd45ee88c-8b27-4be8-8d81-77dda1b81826',
        merchant_id: 'dd36b936-1eb7-4ece-bebc-b514c6a36ebd',
        user_id: 'b58d7eee-e68d-4d12-a1f8-62f5e71382ae',
        nickname: 'VISA: Carl Junior Sr. (ending in: 1111)',
        is_default: 1,
        method: 'card',
        person_name: 'Carl Junior Sr.',
        card_type: 'visa',
        card_last_four: '1111',
        card_exp: '042019',
        bank_name: nil,
        bank_type: nil,
        bank_holder_type: nil,
        address_1: nil,
        address_2: nil,
        address_city: nil,
        address_state: nil,
        address_zip: '32944',
        address_country: 'USA',
        purged_at: nil,
        deleted_at: nil,
        created_at: '2017-05-10 19:54:04',
        updated_at: '2017-05-10 19:54:04',
        card_exp_datetime: '2019-04-30 23:59:59'
      }
      
      stub_request(:put, "https://apiprod.fattlabs.com/payment-method/#{payment_method_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: update_params.to_json
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      payment_method = @client.update_payment_method(payment_method_id, update_params)
      
      assert_instance_of StaxPayments::PaymentMethod, payment_method
      assert_equal payment_method_id, payment_method.id
      assert_equal 'd45ee88c-8b27-4be8-8d81-77dda1b81826', payment_method.customer_id
      assert_equal 'Carl Junior Sr.', payment_method.person_name
      assert_equal 'visa', payment_method.card_type
      assert_equal '1111', payment_method.card_last_four
      assert_equal '042019', payment_method.card_exp
      assert_equal '32944', payment_method.address_zip
      assert_equal 'USA', payment_method.address_country
      assert payment_method.default?
    end
    
    def test_update_payment_method_not_found
      payment_method_id = 'invalid_id'
      update_params = {
        person_name: 'Carl Junior Sr.',
        card_exp: '032020'
      }
      
      error_response = {
        id: [
          "The selected id is invalid."
        ]
      }
      
      stub_request(:put, "https://apiprod.fattlabs.com/payment-method/#{payment_method_id}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: update_params.to_json
        )
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.update_payment_method(payment_method_id, update_params)
      
      assert_instance_of StaxPayments::StaxError, result
      assert_equal 422, result.status_code
      assert_equal error_response, result.error_details
    end
    
    def test_update_payment_method_invalid_params
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      
      # Test invalid person_name format
      invalid_params = {
        person_name: 'Carl'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal 'The person_name must include first and last name separated by a space', error.message
      
      # Test invalid card_last_four
      invalid_params = {
        card_last_four: 'abcd'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal 'The card_last_four must be numeric and maximum 4 digits', error.message
      
      # Test invalid card_exp format
      invalid_params = {
        card_exp: '03/20'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal 'The card_exp must be 4 digits (e.g., "0427" for April 2027)', error.message
      
      # Test invalid bank_type
      invalid_params = {
        bank_type: 'invalid'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal "The bank_type must be 'checking' or 'savings'", error.message
      
      # Test invalid bank_holder_type
      invalid_params = {
        bank_holder_type: 'invalid'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal "The bank_holder_type must be 'personal' or 'business'", error.message
      
      # Test invalid address_state
      invalid_params = {
        address_state: 'Florida'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal 'The address_state must be 2 characters', error.message
      
      # Test invalid address_country
      invalid_params = {
        address_country: 'United States'
      }
      
      error = assert_raises(StaxError) do
        @client.update_payment_method(payment_method_id, invalid_params)
      end
      
      assert_equal 'The address_country must be 3 characters', error.message
    end
    
    def test_share_payment_method
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      gateway_token = '237c78vnYCN201Ib0ZAEzlZ4d0l'
      
      expected_response = {
        "0" => {
          "transaction" => {
            "created_at" => "2022-05-09T11:31:24Z",
            "currency_code" => nil,
            "updated_at" => "2022-05-09T11:31:24Z",
            "succeeded" => true,
            "token" => "IDZJzXNXkqiLk3dQY5LecxarSMp",
            "state" => "succeeded",
            "gateway_specific_fields" => nil,
            "gateway_specific_response_fields" => {
              "provider" => {}
            },
            "transaction_type" => "Store",
            "third_party_token" => nil,
            "gateway_transaction_id" => "cus_LeoRJx05gH5FnG|card_1KxUoCBkOJcrLi5mLgUkB7Zu",
            "gateway_latency_ms" => 668,
            "message_key" => "messages.transaction_succeeded",
            "message" => "Succeeded!",
            "gateway_token" => "237c78vnYCN201Ib0ZAEzlZ4d0l",
            "gateway_type" => "third party gateway",
            "payment_method" => {
              "token" => "KVVQGbZgCzwMnhptyDNnhtyAk27",
              "created_at" => "2022-05-09T11:31:24Z",
              "updated_at" => "2022-05-09T11:31:24Z",
              "gateway_type" => "third_party_gateway",
              "storage_state" => "retained",
              "metadata" => nil,
              "third_party_token" => "cus_LeoRJx05gH5FnG|card_1KxUoCBkOJcrLi5mLgUkB7Zu",
              "payment_method_type" => "third_party_token",
              "errors" => []
            },
            "basis_payment_method" => {
              "token" => "KQYeXq7dKFA37x29rSrj4gvPSSV",
              "created_at" => "2022-03-21T15:13:46Z",
              "updated_at" => "2022-05-09T11:31:24Z",
              "email" => nil,
              "data" => nil,
              "storage_state" => "retained",
              "test" => true,
              "metadata" => nil,
              "callback_url" => nil,
              "last_four_digits" => "1111",
              "first_six_digits" => "411111",
              "card_type" => "visa",
              "first_name" => "Jimiy",
              "last_name" => "Test",
              "month" => 12,
              "year" => 2022,
              "address1" => nil,
              "address2" => nil,
              "city" => nil,
              "state" => nil,
              "zip" => nil,
              "country" => nil,
              "phone_number" => nil,
              "company" => nil,
              "full_name" => "Jimiy Test",
              "eligible_for_card_updater" => true,
              "shipping_address1" => nil,
              "shipping_address2" => nil,
              "shipping_city" => nil,
              "shipping_state" => nil,
              "shipping_zip" => nil,
              "shipping_country" => nil,
              "shipping_phone_number" => nil,
              "issuer_identification_number" => "41111111",
              "payment_method_type" => "credit_card",
              "errors" => [],
              "fingerprint" => "e3cef43464fc832f6e04f187df25af497994",
              "verification_value" => "",
              "number" => "XXXX-XXXX-XXXX-1111"
            },
            "response" => {
              "success" => true,
              "message" => "Transaction approved",
              "avs_code" => nil,
              "avs_message" => nil,
              "cvv_code" => nil,
              "cvv_message" => nil,
              "pending" => false,
              "result_unknown" => false,
              "error_code" => nil,
              "error_detail" => nil,
              "cancelled" => false,
              "fraud_review" => nil,
              "created_at" => "2022-05-09T11:31:24Z",
              "updated_at" => "2022-05-09T11:31:24Z"
            }
          }
        },
        "success" => [
          "payment method successfully submitted"
        ]
      }
      
      stub_request(:post, "https://apiprod.fattlabs.com/payment_method/#{payment_method_id}/external_vault")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: { gateway_token: gateway_token }.to_json
        )
        .to_return(
          status: 201,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.share_payment_method(payment_method_id, gateway_token)
      
      assert_equal expected_response, result
      assert_equal "IDZJzXNXkqiLk3dQY5LecxarSMp", result["0"]["transaction"]["token"]
      assert_equal "cus_LeoRJx05gH5FnG|card_1KxUoCBkOJcrLi5mLgUkB7Zu", result["0"]["transaction"]["payment_method"]["third_party_token"]
      assert_equal true, result["0"]["transaction"]["succeeded"]
      assert_equal ["payment method successfully submitted"], result["success"]
    end
    
    def test_share_payment_method_not_found
      payment_method_id = 'invalid_id'
      gateway_token = '237c78vnYCN201Ib0ZAEzlZ4d0l'
      
      error_response = {
        "error" => [
          "no payment method found."
        ]
      }
      
      stub_request(:post, "https://apiprod.fattlabs.com/payment_method/#{payment_method_id}/external_vault")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          body: { gateway_token: gateway_token }.to_json
        )
        .to_return(
          status: 422,
          body: error_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.share_payment_method(payment_method_id, gateway_token)
      
      assert_instance_of StaxPayments::StaxError, result
      assert_equal 422, result.status_code
      assert_equal error_response, result.error_details
    end
    
    def test_share_payment_method_missing_gateway_token
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      
      error = assert_raises(StaxError) do
        @client.share_payment_method(payment_method_id, nil)
      end
      
      assert_equal 'The gateway_token is required', error.message
      
      error = assert_raises(StaxError) do
        @client.share_payment_method(payment_method_id, '')
      end
      
      assert_equal 'The gateway_token is required', error.message
    end
    
    def test_review_surcharge
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      total = 12.00
      
      expected_response = {
        bin_type: 'CREDIT',
        surcharge_rate: 1.5,
        surcharge_amount: 0.18,
        total_with_surcharge_amount: 12.18
      }
      
      stub_request(:get, "https://apiprod.fattlabs.com/surcharge/review")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          query: {
            payment_method_id: payment_method_id,
            total: total
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.review_surcharge(payment_method_id, total)
      
      assert_equal expected_response, result
      assert_equal 'CREDIT', result[:bin_type]
      assert_equal 1.5, result[:surcharge_rate]
      assert_equal 0.18, result[:surcharge_amount]
      assert_equal 12.18, result[:total_with_surcharge_amount]
    end
    
    def test_review_surcharge_with_string_total
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      total = '12.00'
      
      expected_response = {
        bin_type: 'CREDIT',
        surcharge_rate: 1.5,
        surcharge_amount: 0.18,
        total_with_surcharge_amount: 12.18
      }
      
      stub_request(:get, "https://apiprod.fattlabs.com/surcharge/review")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          query: {
            payment_method_id: payment_method_id,
            total: total
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.review_surcharge(payment_method_id, total)
      
      assert_equal expected_response, result
    end
    
    def test_review_surcharge_with_debit_card
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      total = 12.00
      
      expected_response = {
        bin_type: 'DEBIT',
        surcharge_rate: 0,
        surcharge_amount: 0,
        total_with_surcharge_amount: 12.00
      }
      
      stub_request(:get, "https://apiprod.fattlabs.com/surcharge/review")
        .with(
          headers: {
            'Accept' => '*/*',
            'Authorization' => 'Bearer test_key',
            'Content-Type' => 'application/json'
          },
          query: {
            payment_method_id: payment_method_id,
            total: total
          }
        )
        .to_return(
          status: 200,
          body: expected_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = @client.review_surcharge(payment_method_id, total)
      
      assert_equal expected_response, result
      assert_equal 'DEBIT', result[:bin_type]
      assert_equal 0, result[:surcharge_rate]
      assert_equal 0, result[:surcharge_amount]
      assert_equal 12.00, result[:total_with_surcharge_amount]
    end
    
    def test_review_surcharge_missing_payment_method_id
      error = assert_raises(StaxError) do
        @client.review_surcharge(nil, 12.00)
      end
      
      assert_equal 'The payment_method_id is required', error.message
      
      error = assert_raises(StaxError) do
        @client.review_surcharge('', 12.00)
      end
      
      assert_equal 'The payment_method_id is required', error.message
    end
    
    def test_review_surcharge_missing_total
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      
      error = assert_raises(StaxError) do
        @client.review_surcharge(payment_method_id, nil)
      end
      
      assert_equal 'The total is required', error.message
    end
    
    def test_review_surcharge_invalid_total
      payment_method_id = '6ba7babe-9906-4e7e-b1a5-f628c7badb61'
      
      error = assert_raises(StaxError) do
        @client.review_surcharge(payment_method_id, 0)
      end
      
      assert_equal 'The total must be greater than 0', error.message
      
      error = assert_raises(StaxError) do
        @client.review_surcharge(payment_method_id, -1)
      end
      
      assert_equal 'The total must be greater than 0', error.message
    end
  end
end 