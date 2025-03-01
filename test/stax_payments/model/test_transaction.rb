# frozen_string_literal: true

require 'test_helper'

class TestTransaction < Minitest::Test
  def setup
    @transaction_data = {
      id: 'txn_123456789',
      amount: 1000,
      currency: 'USD',
      status: 'completed',
      type: 'charge',
      customer_id: 'cus_123456789',
      payment_method_id: 'pm_123456789',
      payment_method_type: 'card',
      description: 'Test transaction',
      reference_id: 'ref_123456789',
      order_id: 'ord_123456789',
      invoice_id: 'inv_123456789',
      created_at: '2023-01-01T00:00:00Z',
      updated_at: '2023-01-01T00:00:00Z'
    }
    @transaction = StaxPayments::Transaction.new(@transaction_data)
  end

  def test_initialization
    assert_equal 'txn_123456789', @transaction.id
    assert_equal 1000, @transaction.amount
    assert_equal 'USD', @transaction.currency
    assert_equal 'completed', @transaction.status
    assert_equal 'charge', @transaction.type
    assert_equal 'cus_123456789', @transaction.customer_id
    assert_equal 'pm_123456789', @transaction.payment_method_id
    assert_equal 'card', @transaction.payment_method_type
    assert_equal 'Test transaction', @transaction.description
    assert_equal 'ref_123456789', @transaction.reference_id
    assert_equal 'ord_123456789', @transaction.order_id
    assert_equal 'inv_123456789', @transaction.invoice_id
  end

  def test_status_helper_methods
    assert_equal false, @transaction.pending?
    assert_equal true, @transaction.completed?
    assert_equal false, @transaction.failed?
    assert_equal false, @transaction.voided?
    assert_equal false, @transaction.refunded?
    
    transaction = StaxPayments::Transaction.new(@transaction_data.merge(status: 'pending'))
    assert_equal true, transaction.pending?
    assert_equal false, transaction.completed?
  end

  def test_type_helper_methods
    assert_equal true, @transaction.charge?
    assert_equal false, @transaction.refund?
    assert_equal false, @transaction.authorization?
    assert_equal false, @transaction.capture?
    assert_equal false, @transaction.void?
    
    transaction = StaxPayments::Transaction.new(@transaction_data.merge(type: 'refund'))
    assert_equal false, transaction.charge?
    assert_equal true, transaction.refund?
  end

  def test_amount_in_dollars
    assert_equal 10.0, @transaction.amount_in_dollars
    
    transaction = StaxPayments::Transaction.new(@transaction_data.merge(amount: 2550))
    assert_equal 25.5, transaction.amount_in_dollars
    
    transaction = StaxPayments::Transaction.new(@transaction_data.merge(amount: nil))
    assert_nil transaction.amount_in_dollars
  end
end 