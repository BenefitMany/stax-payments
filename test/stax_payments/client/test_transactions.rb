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
end 