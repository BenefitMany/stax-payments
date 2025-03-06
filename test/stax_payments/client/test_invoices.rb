# frozen_string_literal: true

require 'test_helper'

class TestInvoices < Minitest::Test
  def setup
    @client = StaxPayments::Client.new(api_key: 'test_api_key')
    @invoice_id = '9ddcf02b-c2be-4f27-b758-dbc12b2aa924'
    
    # Mock response for delete_invoice
    @delete_invoice_response = {
      id: @invoice_id,
      merchant_id: 'dd36b936-1eb7-4ece-bebc-b514c6a36ebd',
      user_id: 'b58d7eee-e68d-4d12-a1f8-62f5e71382ae',
      customer_id: 'd45ee88c-8b27-4be8-8d81-77dda1b81826',
      total: 100,
      meta: {
        tax: 0,
        subtotal: 10,
        line_items: [
          {
            id: 'optional-fm-catalog-item-id',
            item: 'Demo Item',
            details: 'this is a regular demo item',
            quantity: 1,
            price: 100
          }
        ]
      },
      status: 'DELETED',
      sent_at: nil,
      viewed_at: nil,
      paid_at: nil,
      schedule_id: nil,
      reminder_id: nil,
      payment_method_id: 'd3050b19-77d9-44ac-9851-b1d1680a7684',
      url: 'https://app.staxpayments.com/#/bill/',
      is_webpayment: false,
      deleted_at: '2017-05-08 21:43:19',
      created_at: '2017-05-08 21:32:51',
      updated_at: '2017-05-08 21:43:19',
      payment_attempt_failed: false,
      payment_attempt_message: '',
      balance_due: 100,
      total_paid: 0,
      payment_meta: [],
      customer: {
        id: 'd45ee88c-8b27-4be8-8d81-77dda1b81826',
        firstname: 'John',
        lastname: 'Smith',
        company: 'ABC INC',
        email: 'demo@abc.com',
        cc_emails: [
          'demo1@abc.com',
          'demo2@abc.com'
        ],
        phone: '1234567898',
        address_1: '123 Rite Way',
        address_2: 'Unit 12',
        address_city: 'Orlando',
        address_state: 'FL',
        address_zip: '32801',
        address_country: 'USA',
        notes: nil,
        reference: 'BARTLE',
        options: '',
        created_at: '2017-05-08 19:22:51',
        updated_at: '2017-05-08 19:23:46',
        deleted_at: nil,
        gravatar: '//www.gravatar.com/avatar/fe3e929dd80f1653c3a4b82812660061'
      },
      user: {
        id: 'b58d7eee-e68d-4d12-a1f8-62f5e71382ae',
        system_admin: false,
        name: 'Demo',
        email: 'contact@example.com',
        email_verification_sent_at: '2017-03-29 15:27:19',
        email_verified_at: '2017-03-29 15:27:21',
        is_api_key: false,
        created_at: '2017-01-11 21:44:02',
        updated_at: '2017-04-24 15:41:58',
        deleted_at: nil,
        gravatar: '//www.gravatar.com/avatar/157965dea7cd2f44e349382d1d791650',
        team_admin: nil,
        team_enabled: nil,
        team_role: nil
      },
      files: [],
      child_transactions: [],
      reminder: nil
    }
    
    # Mock response for delete_invoice with error
    @delete_invoice_error_response = {
      deleted_at: [
        'The invoice is already deleted.'
      ]
    }
    
    # Mock response for send_invoice_email
    @send_invoice_email_response = {
      id: '4bbd1a64-7472-44ed-afef-02b82d3eae24',
      merchant_id: 'dee75215-b3bc-4e44-9bc5-75d0fb498b61',
      user_id: '7c30a7f6-eabc-4355-b530-d351f8f0a4f1',
      customer_id: 'a41c93d0-e45d-4d41-b46c-f781a02019f5',
      total: 12,
      meta: {
        tax: 2,
        subtotal: 10,
        line_items: [
          {
            id: 'optional-fm-catalog-item-id',
            item: 'Demo Item',
            details: 'this is a regular demo item',
            quantity: 1,
            price: 10
          }
        ]
      },
      status: 'SENT',
      sent_at: '2016-05-09 17:10:43',
      viewed_at: nil,
      paid_at: nil,
      url: 'http://127.0.0.1:5477/#/bill/',
      deleted_at: nil,
      created_at: '2016-05-09 17:10:37',
      updated_at: '2016-05-09 17:10:43',
      customer: {
        id: 'a41c93d0-e45d-4d41-b46c-f781a02019f5',
        firstname: 'Jason',
        lastname: 'Mann',
        company: 'CIA',
        email: 'JasonGuy@CIA.com',
        phone: '1234567898',
        address_1: '123 Rite Way',
        address_2: 'Unit 12',
        address_city: 'Orlando',
        address_state: 'FL',
        address_zip: '32801',
        notes: '',
        options: '',
        created_at: '2016-04-26 13:55:21',
        updated_at: '2016-04-26 13:55:21',
        deleted_at: nil,
        payment_attempt_failed: false,
        payment_attempt_message: '',
        gravatar: '//www.gravatar.com/avatar/1b91155f027795b2d36a08b1e5e8e9df'
      },
      user: {
        id: '7c30a7f6-eabc-4355-b530-d351f8f0a4f1',
        system_admin: true,
        name: 'DANIEL WALKER',
        email: 'contact@example.com',
        created_at: '2016-04-12 13:52:26',
        updated_at: '2016-04-25 16:46:42',
        deleted_at: nil,
        gravatar: '//www.gravatar.com/avatar/772cbf95746d7da86789cc3634c46ba8'
      },
      child_transactions: []
    }
    
    # Mock response for send_invoice_email with error
    @send_invoice_email_error_response = {
      id: [
        'Invoice could not be found'
      ]
    }
    
    # Mock response for send_invoice_sms
    @send_invoice_sms_response = {
      id: '4bbd1a64-7472-44ed-afef-02b82d3eae24',
      merchant_id: 'dee75215-b3bc-4e44-9bc5-75d0fb498b61',
      user_id: '7c30a7f6-eabc-4355-b530-d351f8f0a4f1',
      customer_id: 'a41c93d0-e45d-4d41-b46c-f781a02019f5',
      total: 12,
      meta: {
        tax: 2,
        subtotal: 10,
        line_items: [
          {
            id: 'optional-fm-catalog-item-id',
            item: 'Demo Item',
            details: 'this is a regular demo item',
            quantity: 1,
            price: 10
          }
        ]
      },
      status: 'SENT',
      sent_at: '2016-05-09 17:10:43',
      viewed_at: nil,
      paid_at: nil,
      url: 'http://127.0.0.1:5477/#/bill/',
      deleted_at: nil,
      created_at: '2016-05-09 17:10:37',
      updated_at: '2016-05-09 17:10:43',
      customer: {
        id: 'a41c93d0-e45d-4d41-b46c-f781a02019f5',
        firstname: 'Jason',
        lastname: 'Mann',
        company: 'CIA',
        email: 'JasonGuy@CIA.com',
        phone: '1234567898',
        address_1: '123 Rite Way',
        address_2: 'Unit 12',
        address_city: 'Orlando',
        address_state: 'FL',
        address_zip: '32801',
        notes: '',
        options: '',
        created_at: '2016-04-26 13:55:21',
        updated_at: '2016-04-26 13:55:21',
        deleted_at: nil,
        payment_attempt_failed: false,
        payment_attempt_message: '',
        gravatar: '//www.gravatar.com/avatar/1b91155f027795b2d36a08b1e5e8e9df'
      },
      user: {
        id: '7c30a7f6-eabc-4355-b530-d351f8f0a4f1',
        system_admin: true,
        name: 'DANIEL WALKER',
        email: 'contact@example.com',
        created_at: '2016-04-12 13:52:26',
        updated_at: '2016-04-25 16:46:42',
        deleted_at: nil,
        gravatar: '//www.gravatar.com/avatar/772cbf95746d7da86789cc3634c46ba8'
      },
      child_transactions: []
    }
    
    # Mock response for send_invoice_sms with error
    @send_invoice_sms_error_response = [
      {
        id: [
          'Invoice could not be found'
        ]
      },
      {
        phoneNumber: '111111111111111',
        status: 'failure',
        message: 'please contact your customer for a valid phone number to use.'
      }
    ]
  end
  
  def test_delete_invoice
    # Mock the API request
    @client.stub :process_request, @delete_invoice_response do
      # Call the method
      invoice = @client.delete_invoice(@invoice_id)
      
      # Assert the result is an Invoice object
      assert_instance_of StaxPayments::Invoice, invoice
      
      # Assert the invoice properties
      assert_equal @invoice_id, invoice.id
      assert_equal 'DELETED', invoice.status
      assert_equal '2017-05-08 21:43:19', invoice.deleted_at
      assert invoice.deleted?
    end
  end
  
  def test_delete_invoice_error
    # Create a StaxError with the error response
    error = StaxPayments::StaxError.new(nil)
    error.instance_variable_set(:@error_details, @delete_invoice_error_response)
    
    # Mock the API request to return the error
    @client.stub :process_request, error do
      # Call the method
      result = @client.delete_invoice(@invoice_id)
      
      # Assert the result is a StaxError
      assert_instance_of StaxPayments::StaxError, result
      
      # Assert the error details
      assert_equal @delete_invoice_error_response, result.error_details
    end
  end
  
  def test_send_invoice_email
    # Mock the API request
    @client.stub :process_request, @send_invoice_email_response do
      # Call the method with CC emails
      cc_emails = ['contactCC@example.com', 'contactCC2@example.com']
      invoice = @client.send_invoice_email(@invoice_id, { cc_emails: cc_emails })
      
      # Assert the result is an Invoice object
      assert_instance_of StaxPayments::Invoice, invoice
      
      # Assert the invoice properties
      assert_equal '4bbd1a64-7472-44ed-afef-02b82d3eae24', invoice.id
      assert_equal 'SENT', invoice.status
      assert_equal '2016-05-09 17:10:43', invoice.sent_at
      assert invoice.sent?
    end
  end
  
  def test_send_invoice_email_error
    # Create a StaxError with the error response
    error = StaxPayments::StaxError.new(nil)
    error.instance_variable_set(:@error_details, @send_invoice_email_error_response)
    
    # Mock the API request to return the error
    @client.stub :process_request, error do
      # Call the method
      result = @client.send_invoice_email(@invoice_id, { cc_emails: ['test@example.com'] })
      
      # Assert the result is a StaxError
      assert_instance_of StaxPayments::StaxError, result
      
      # Assert the error details
      assert_equal @send_invoice_email_error_response, result.error_details
    end
  end
  
  def test_send_invoice_email_validation
    # Test validation of cc_emails parameter
    assert_raises(StaxPayments::StaxError) do
      @client.send_invoice_email(@invoice_id, { cc_emails: 'not_an_array' })
    end
  end
  
  def test_send_invoice_sms
    # Mock the API request
    @client.stub :process_request, @send_invoice_sms_response do
      # Call the method with phone and message
      phone = '5555555555'
      message = 'Your invoice is ready for payment'
      invoice = @client.send_invoice_sms(@invoice_id, { phone: phone, message: message })
      
      # Assert the result is an Invoice object
      assert_instance_of StaxPayments::Invoice, invoice
      
      # Assert the invoice properties
      assert_equal '4bbd1a64-7472-44ed-afef-02b82d3eae24', invoice.id
      assert_equal 'SENT', invoice.status
      assert_equal '2016-05-09 17:10:43', invoice.sent_at
      assert invoice.sent?
    end
  end
  
  def test_send_invoice_sms_error
    # Create a StaxError with the error response
    error = StaxPayments::StaxError.new(nil)
    error.instance_variable_set(:@error_details, @send_invoice_sms_error_response)
    
    # Mock the API request to return the error
    @client.stub :process_request, error do
      # Call the method
      result = @client.send_invoice_sms(@invoice_id, { phone: '1111111111' })
      
      # Assert the result is a StaxError
      assert_instance_of StaxPayments::StaxError, result
      
      # Assert the error details
      assert_equal @send_invoice_sms_error_response, result.error_details
    end
  end
  
  def test_send_invoice_sms_validation_missing_phone
    # Test validation of required phone parameter
    assert_raises(StaxPayments::StaxError) do
      @client.send_invoice_sms(@invoice_id, { message: 'Test message' })
    end
  end
  
  def test_send_invoice_sms_validation_invalid_phone
    # Test validation of phone format
    assert_raises(StaxPayments::StaxError) do
      @client.send_invoice_sms(@invoice_id, { phone: 'not-a-phone-number' })
    end
    
    assert_raises(StaxPayments::StaxError) do
      @client.send_invoice_sms(@invoice_id, { phone: '123' }) # Too short
    end
    
    assert_raises(StaxPayments::StaxError) do
      @client.send_invoice_sms(@invoice_id, { phone: 123456789 }) # Not a string
    end
  end
end 