# frozen_string_literal: true

require 'test_helper'

class TestTransactionsClient < Minitest::Test
  def setup
    @client = StaxPayments::Client.new(
      api_key: 'test_key',
      api_secret: 'test_secret'
    )
    
    # Sample transaction data for testing
    @transaction_data = {
      id: 'txn_123456789',
      amount: 1000,
      currency: 'USD',
      status: 'completed',
      type: 'charge',
      customer_id: 'cus_123456789',
      payment_method_id: 'pm_123456789',
      payment_method_type: 'card',
      description: 'Test transaction'
    }
  end

  def test_list_transactions
    # Mock the API response
    expected_response = {
      transactions: [
        @transaction_data,
        @transaction_data.merge(id: 'txn_987654321')
      ]
    }
    
    @client.expects(:process_request).with(:get, 'transactions', params: {}).returns(expected_response)
    
    transactions = @client.transactions
    assert_equal 2, transactions.length
    assert_instance_of StaxPayments::Transaction, transactions.first
    assert_equal 'txn_123456789', transactions.first.id
    assert_equal 'txn_987654321', transactions.last.id
  end

  def test_list_transactions_with_filters
    filters = {
      customer_id: 'cus_123456789',
      status: 'completed',
      start_date: '2023-01-01',
      end_date: '2023-01-31'
    }
    
    expected_response = {
      transactions: [
        @transaction_data
      ]
    }
    
    @client.expects(:process_request).with(:get, 'transactions', params: filters).returns(expected_response)
    
    transactions = @client.transactions(filters)
    assert_equal 1, transactions.length
    assert_instance_of StaxPayments::Transaction, transactions.first
    assert_equal 'txn_123456789', transactions.first.id
  end

  def test_get_transaction
    expected_response = {
      transaction: @transaction_data
    }
    
    @client.expects(:process_request).with(:get, 'transactions/txn_123456789').returns(expected_response)
    
    transaction = @client.transaction('txn_123456789')
    assert_instance_of StaxPayments::Transaction, transaction
    assert_equal 'txn_123456789', transaction.id
    assert_equal 1000, transaction.amount
    assert_equal 'completed', transaction.status
  end

  def test_search_transactions
    search_params = {
      customer_id: 'cus_123456789',
      min_amount: 500,
      max_amount: 2000,
      start_date: '2023-01-01',
      end_date: '2023-01-31'
    }
    
    expected_response = {
      transactions: [
        @transaction_data,
        @transaction_data.merge(id: 'txn_987654321', amount: 1500)
      ]
    }
    
    @client.expects(:process_request).with(:post, 'transactions/search', body: search_params).returns(expected_response)
    
    transactions = @client.search_transactions(search_params)
    assert_equal 2, transactions.length
    assert_instance_of StaxPayments::Transaction, transactions.first
    assert_equal 'txn_123456789', transactions.first.id
    assert_equal 'txn_987654321', transactions.last.id
    assert_equal 1500, transactions.last.amount
  end

  def test_transaction_summary
    params = {
      start_date: '2023-01-01',
      end_date: '2023-01-31',
      group_by: 'day'
    }
    
    expected_response = {
      summary: {
        total_amount: 10000,
        total_count: 10,
        average_amount: 1000,
        by_day: [
          { date: '2023-01-01', amount: 2000, count: 2 },
          { date: '2023-01-02', amount: 3000, count: 3 }
        ]
      }
    }
    
    @client.expects(:process_request).with(:get, 'transactions/summary', params: params).returns(expected_response)
    
    summary = @client.transaction_summary(params)
    assert_equal 10000, summary[:total_amount]
    assert_equal 10, summary[:total_count]
    assert_equal 2, summary[:by_day].length
  end

  def test_export_transactions
    params = {
      format: 'csv',
      start_date: '2023-01-01',
      end_date: '2023-01-31'
    }
    
    expected_response = {
      export_url: 'https://api.staxpayments.com/exports/transactions_123456789.csv'
    }
    
    @client.expects(:process_request).with(:post, 'transactions/export', body: params).returns(expected_response)
    
    export_url = @client.export_transactions(params)
    assert_equal 'https://api.staxpayments.com/exports/transactions_123456789.csv', export_url
  end

  def test_capture_transaction
    transaction_id = 'txn_123456789'
    
    # Expected response for a captured transaction
    expected_response = {
      id: transaction_id,
      type: 'capture',
      success: true,
      total: 5.00,
      method: 'card',
      pre_auth: false,
      is_captured: 0,
      last_four: '1111',
      created_at: '2023-03-01T12:00:00Z',
      customer_id: 'cus_123456789',
      payment_method_id: 'pm_123456789'
    }
    
    # Test with a specific capture amount
    capture_args = { total: 5.00 }
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/capture", body: capture_args)
           .returns(expected_response)
    
    transaction = @client.capture_transaction(transaction_id, capture_args)
    
    assert_instance_of StaxPayments::Transaction, transaction
    assert_equal transaction_id, transaction.id
    assert_equal 'capture', transaction.type
    assert_equal true, transaction.success
    assert_equal 5.00, transaction.total
    assert_equal 'card', transaction.method
    assert_equal false, transaction.pre_auth
  end
  
  def test_capture_transaction_full_amount
    transaction_id = 'txn_123456789'
    
    # Expected response for a captured transaction (full amount)
    expected_response = {
      id: transaction_id,
      type: 'capture',
      success: true,
      total: 10.00,
      method: 'card',
      pre_auth: false,
      is_captured: 0,
      last_four: '1111',
      created_at: '2023-03-01T12:00:00Z',
      customer_id: 'cus_123456789',
      payment_method_id: 'pm_123456789'
    }
    
    # Test with no arguments (captures full amount)
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/capture", body: {})
           .returns(expected_response)
    
    transaction = @client.capture_transaction(transaction_id)
    
    assert_instance_of StaxPayments::Transaction, transaction
    assert_equal transaction_id, transaction.id
    assert_equal 'capture', transaction.type
    assert_equal true, transaction.success
    assert_equal 10.00, transaction.total
    assert_equal 'card', transaction.method
    assert_equal false, transaction.pre_auth
  end
  
  def test_capture_transaction_error
    transaction_id = 'invalid_transaction_id'
    
    # Error response
    error_response = {
      status: 'error',
      message: 'The selected id is invalid.',
      error_code: 'invalid_transaction_id'
    }
    
    # Create a StaxError object
    stax_error = StaxPayments::StaxError.new('The selected id is invalid.')
    stax_error.status_code = 422
    stax_error.error_details = { 'id' => ['The selected id is invalid.'] }
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/capture", body: {})
           .returns(stax_error)
    
    result = @client.capture_transaction(transaction_id)
    
    assert_instance_of StaxPayments::StaxError, result
    assert_equal 'The selected id is invalid.', result.message
    assert_equal 422, result.status_code
    assert_equal({ 'id' => ['The selected id is invalid.'] }, result.error_details)
  end

  def test_void_transaction
    transaction_id = 'ba9bf00c-c54d-48f8-8400-902cb3aacd21'
    
    # Expected response for a voided transaction
    expected_response = {
      id: transaction_id,
      invoice_id: '',
      reference_id: '',
      recurring_transaction_id: '',
      type: 'charge',
      source: nil,
      merchant_id: 'dd36b936-1eb7-4ece-bebc-b514c6a36ebd',
      user_id: '41e60252-4f23-48de-a64f-e5a1e8a9359c',
      customer_id: 'd45ee88c-8b27-4be8-8d81-77dda1b81826',
      payment_method_id: '129520d1-3844-45fd-a0b1-afb66bcdc74c',
      is_manual: nil,
      success: true,
      message: nil,
      meta: {
        tax: 2,
        subtotal: 10
      },
      total: 1,
      method: 'card',
      pre_auth: false,
      last_four: '1111',
      receipt_email_at: '2017-05-19 14:40:31',
      receipt_sms_at: nil,
      created_at: '2017-05-19 13:50:44',
      updated_at: '2017-05-19 14:40:31',
      total_refunded: nil,
      is_refundable: false,
      is_voided: true,
      is_voidable: false,
      schedule_id: nil,
      child_transactions: [
        {
          id: '04497525-565c-4169-bb6d-5a4df399d255',
          type: 'void',
          success: true
        }
      ]
    }
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/void")
           .returns(expected_response)
    
    transaction = @client.void_transaction(transaction_id)
    
    assert_instance_of StaxPayments::Transaction, transaction
    assert_equal transaction_id, transaction.id
    assert_equal true, transaction.is_voided
    assert_equal false, transaction.is_voidable
    assert_equal 'charge', transaction.type
    assert_equal true, transaction.success
  end
  
  def test_void_transaction_error
    transaction_id = 'already_voided_transaction'
    
    # Error response
    error_response = {
      total: [
        'The transaction has already been voided.'
      ]
    }
    
    # Create a StaxError object
    stax_error = StaxPayments::StaxError.new('The transaction has already been voided.')
    stax_error.status_code = 422
    stax_error.error_details = error_response
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/void")
           .returns(stax_error)
    
    result = @client.void_transaction(transaction_id)
    
    assert_instance_of StaxPayments::StaxError, result
    assert_equal 'The transaction has already been voided.', result.message
    assert_equal 422, result.status_code
    assert_equal error_response, result.error_details
  end

  def test_refund_transaction
    transaction_id = '4daf3bdd-a23a-4363-b5c3-041ce431e301'
    refund_amount = 5.00
    
    # Expected response for a refunded transaction
    expected_response = {
      id: transaction_id,
      invoice_id: '2f463135-c62f-4f54-9e18-58f616e7a56d',
      reference_id: '',
      recurring_transaction_id: '',
      type: 'charge',
      source: nil,
      merchant_id: 'dd36b936-1eb7-4ece-bebc-b514c6a36ebd',
      user_id: 'b58d7eee-e68d-4d12-a1f8-62f5e71382ae',
      customer_id: 'ffed4fd2-977e-412f-9048-293bb5e46c68',
      payment_method_id: 'ad03da14-4f2b-4b43-8e12-e8d784018d79',
      is_manual: nil,
      success: true,
      message: nil,
      meta: {
        lineItems: [
          {
            item: '',
            details: '',
            quantity: 1,
            price: '123'
          }
        ],
        memo: '',
        subtotal: 123,
        tax: '',
        type: 'invoice/schedule'
      },
      total: 123,
      method: 'card',
      pre_auth: false,
      last_four: '1111',
      receipt_email_at: nil,
      receipt_sms_at: nil,
      created_at: '2017-05-05 19:51:05',
      updated_at: '2017-05-05 19:51:05',
      total_refunded: 5,
      is_refundable: true,
      is_voided: false,
      is_voidable: false,
      schedule_id: '8b8c4333-29af-4364-8a5e-d8617f31c4ae',
      child_transactions: [
        {
          id: 'fd4e7bad-4982-4747-ab95-4eb87df97a8c',
          invoice_id: '2f463135-c62f-4f54-9e18-58f616e7a56d',
          reference_id: transaction_id,
          recurring_transaction_id: '',
          type: 'refund',
          source: nil,
          merchant_id: 'dd36b936-1eb7-4ece-bebc-b514c6a36ebd',
          user_id: '41e60252-4f23-48de-a64f-e5a1e8a9359c',
          customer_id: 'ffed4fd2-977e-412f-9048-293bb5e46c68',
          payment_method_id: 'ad03da14-4f2b-4b43-8e12-e8d784018d79',
          is_manual: nil,
          success: true,
          message: nil,
          meta: {
            lineItems: [
              {
                item: '',
                details: '',
                quantity: 1,
                price: '123'
              }
            ],
            memo: '',
            subtotal: 123,
            tax: '',
            type: 'invoice/schedule'
          },
          total: 5,
          method: 'card',
          pre_auth: false,
          last_four: '1111',
          receipt_email_at: nil,
          receipt_sms_at: nil,
          created_at: '2017-05-19 15:06:29',
          updated_at: '2017-05-19 15:06:29',
          total_refunded: nil,
          is_refundable: false,
          is_voided: nil,
          is_voidable: false,
          schedule_id: '8b8c4333-29af-4364-8a5e-d8617f31c4ae'
        }
      ]
    }
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/refund", body: { total: refund_amount })
           .returns(expected_response)
    
    transaction = @client.refund_transaction(transaction_id, { total: refund_amount })
    
    assert_instance_of StaxPayments::Transaction, transaction
    assert_equal transaction_id, transaction.id
    assert_equal 5, transaction.total_refunded
    assert_equal true, transaction.is_refundable
    assert_equal false, transaction.is_voided
    assert_equal 1, transaction.child_transactions.length
    assert_equal 'refund', transaction.child_transactions.first[:type]
    assert_equal 5, transaction.child_transactions.first[:total]
  end
  
  def test_refund_transaction_error_missing_total
    transaction_id = '4daf3bdd-a23a-4363-b5c3-041ce431e301'
    
    assert_raises(StaxPayments::StaxError) do
      @client.refund_transaction(transaction_id, {})
    end
  end
  
  def test_refund_transaction_error_api
    transaction_id = 'recent_transaction'
    
    # Error response
    error_response = {
      created_at: [
        'The transaction cannot be refunded within 24 hours of being created.'
      ]
    }
    
    # Create a StaxError object
    stax_error = StaxPayments::StaxError.new('The transaction cannot be refunded within 24 hours of being created.')
    stax_error.status_code = 422
    stax_error.error_details = error_response
    
    @client.expects(:process_request)
           .with(:post, "transaction/#{transaction_id}/refund", body: { total: 5.00 })
           .returns(stax_error)
    
    result = @client.refund_transaction(transaction_id, { total: 5.00 })
    
    assert_instance_of StaxPayments::StaxError, result
    assert_equal 'The transaction cannot be refunded within 24 hours of being created.', result.message
    assert_equal 422, result.status_code
    assert_equal error_response, result.error_details
  end

end 