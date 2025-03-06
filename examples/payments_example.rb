#!/usr/bin/env ruby
# frozen_string_literal: true

require 'dotenv/load'
require 'stax_payments'

# Initialize the Stax Payments client
client = StaxPayments::Client.new(
  api_key: ENV['STAX_API_KEY'],
  api_secret: ENV['STAX_API_SECRET'],
  environment: ENV['STAX_ENVIRONMENT'] || 'sandbox'
)

puts "=== Stax Payments Payment Examples ==="
puts

# Example: List payment methods for a customer
puts "Listing payment methods for a customer..."
begin
  # First, let's get a customer
  customers_result = client.customers(limit: 1)
  customers = customers_result.is_a?(Hash) ? customers_result[:customers] : customers_result
  
  if customers.empty?
    puts "No customers found. Please create a customer first."
  else
    customer_id = customers.first.id
    puts "Using customer: #{customers.first.firstname} #{customers.first.lastname} (ID: #{customer_id})"
    
    # Get payment methods for the customer
    payment_methods = client.customer_payment_methods(customer_id) rescue []
    
    if payment_methods.empty?
      puts "No payment methods found for this customer."
    else
      puts "Found #{payment_methods.size} payment method(s):"
      payment_methods.each do |pm|
        puts "  - #{pm.nickname} (ID: #{pm.id})"
        puts "    Type: #{pm.method}"
        if pm.method == 'card'
          puts "    Card: #{pm.card_type} ending in #{pm.card_last_four}, expires #{pm.card_exp}"
        elsif pm.method == 'bank'
          puts "    Bank: #{pm.bank_name} (#{pm.bank_type})"
        end
        puts
      end
      
      # Store the first payment method ID for later use
      payment_method_id = payment_methods.first.id
    end
  end
rescue => e
  puts "Error listing payment methods: #{e.message}"
  puts
end

# Example: Charge a payment method
puts "Charging a payment method..."
begin
  # Check if we have a payment method ID from the previous example
  if defined?(payment_method_id) && payment_method_id
    # Create a charge
    transaction = client.charge_payment_method({
      payment_method_id: payment_method_id,
      total: 26.00,
      meta: {
        tax: 4,
        subtotal: 20,
        lineItems: [
          {
            item: 'Demo Item',
            details: 'this is a regular demo item',
            quantity: 20,
            price: 1
          }
        ]
      },
      pre_auth: false
    })
    
    puts "Transaction created successfully!"
    puts "Transaction ID: #{transaction.id}"
    puts "Type: #{transaction.type}"
    puts "Status: #{transaction.success ? 'Success' : 'Failed'}"
    if transaction.success
      puts "Amount: $#{transaction.total}"
      puts "Method: #{transaction.method}"
      puts "Created at: #{transaction.created_at}"
      
      # Display payment method details
      if transaction.payment_method
        puts "Payment method: #{transaction.payment_method[:nickname]}"
        puts "Last four: #{transaction.last_four}"
      end
      
      # Display customer details
      if transaction.customer
        puts "Customer: #{transaction.customer[:firstname]} #{transaction.customer[:lastname]}"
        puts "Email: #{transaction.customer[:email]}"
      end
    else
      puts "Error message: #{transaction.message}"
    end
    puts
  else
    puts "No payment method available for charging. Please add a payment method to a customer first."
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error charging payment method: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Charge a payment method with additional options
puts "Charging a payment method with additional options..."
begin
  # Check if we have a payment method ID from the previous example
  if defined?(payment_method_id) && payment_method_id
    # Generate a unique idempotency ID
    idempotency_id = "charge-#{Time.now.to_i}-#{rand(1000)}"
    
    # Create a charge with additional options
    transaction = client.charge_payment_method({
      payment_method_id: payment_method_id,
      total: 42.50,
      meta: {
        tax: 3.50,
        poNumber: '5678',
        shippingAmount: 4.00,
        payment_note: 'This is a test payment with additional options',
        subtotal: 35.00,
        lineItems: [
          {
            item: 'Premium Service',
            details: 'Monthly subscription to premium services',
            quantity: 1,
            price: 35.00
          }
        ],
        transaction_initiation_type: 'CIT',
        transaction_schedule_type: 'unscheduled'
      },
      pre_auth: true,  # Create a pre-authorization
      currency: 'USD',
      idempotency_id: idempotency_id,
      channel: 'api-example'
    })
    
    puts "Pre-authorization created successfully!"
    puts "Transaction ID: #{transaction.id}"
    puts "Type: #{transaction.type}"
    puts "Pre-auth: #{transaction.pre_auth ? 'Yes' : 'No'}"
    puts "Status: #{transaction.success ? 'Success' : 'Failed'}"
    if transaction.success
      puts "Amount: $#{transaction.total}"
      puts "Method: #{transaction.method}"
      puts "Created at: #{transaction.created_at}"
      puts "Idempotency ID: #{idempotency_id}"
      
      # Display payment method details
      if transaction.payment_method
        puts "Payment method: #{transaction.payment_method[:nickname]}"
        puts "Last four: #{transaction.last_four}"
      end
      
      # Display customer details
      if transaction.customer
        puts "Customer: #{transaction.customer[:firstname]} #{transaction.customer[:lastname]}"
        puts "Email: #{transaction.customer[:email]}"
      end
      
      # Store the transaction ID for later use in the capture example
      pre_auth_transaction_id = transaction.id
    else
      puts "Error message: #{transaction.message}"
    end
    puts
  else
    puts "No payment method available for charging. Please add a payment method to a customer first."
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error creating pre-authorization: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Capture a pre-authorized transaction
puts "Capturing a pre-authorized transaction..."
begin
  # Check if we have a pre-auth transaction ID from the previous example
  if defined?(pre_auth_transaction_id) && pre_auth_transaction_id
    # Capture a partial amount of the pre-authorization
    capture_amount = 25.00
    
    # Capture the pre-authorization
    transaction = client.capture_transaction(pre_auth_transaction_id, { total: capture_amount })
    
    puts "Transaction captured successfully!"
    puts "Transaction ID: #{transaction.id}"
    puts "Type: #{transaction.type}"
    puts "Status: #{transaction.success ? 'Success' : 'Failed'}"
    if transaction.success
      puts "Captured amount: $#{transaction.total}"
      puts "Method: #{transaction.method}"
      puts "Created at: #{transaction.created_at}"
      
      # Display payment method details
      if transaction.payment_method
        puts "Payment method: #{transaction.payment_method[:nickname]}"
        puts "Last four: #{transaction.last_four}"
      end
      
      # Display customer details
      if transaction.customer
        puts "Customer: #{transaction.customer[:firstname]} #{transaction.customer[:lastname]}"
        puts "Email: #{transaction.customer[:email]}"
      end
    else
      puts "Error message: #{transaction.message}"
    end
    puts
  else
    puts "No pre-authorized transaction available for capture. Please create a pre-authorization first."
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error capturing transaction: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Verify a payment method
puts "Verifying a payment method..."
begin
  # Check if we have a payment method ID from the previous examples
  if defined?(payment_method_id) && payment_method_id
    # Verify the payment method with a small pre-authorization
    transaction = client.verify_payment_method({
      payment_method_id: payment_method_id,
      total: 1.00,
      meta: {
        tax: 0,
        subtotal: 1.00,
        lineItems: [
          {
            item: 'Payment Method Verification',
            details: 'Verification charge to validate payment method',
            quantity: 1,
            price: 1.00
          }
        ]
      }
    })
    
    puts "Payment method verification completed!"
    puts "Transaction ID: #{transaction.id}"
    puts "Type: #{transaction.type}"
    puts "Pre-auth: #{transaction.pre_auth ? 'Yes' : 'No'}"
    puts "Status: #{transaction.success ? 'Success' : 'Failed'}"
    if transaction.success
      puts "Amount: $#{transaction.total}"
      puts "Method: #{transaction.method}"
      puts "Created at: #{transaction.created_at}"
      
      # Display payment method details
      if transaction.payment_method
        puts "Payment method: #{transaction.payment_method[:nickname]}"
        puts "Last four: #{transaction.last_four}"
      end
      
      # Display customer details
      if transaction.customer
        puts "Customer: #{transaction.customer[:firstname]} #{transaction.customer[:lastname]}"
        puts "Email: #{transaction.customer[:email]}"
      end
      
      puts "\nPayment method is valid and can be used for future transactions."
    else
      puts "Error message: #{transaction.message}"
      puts "\nPayment method verification failed. The payment method may be invalid or declined."
    end
    puts
  else
    puts "No payment method available for verification. Please add a payment method to a customer first."
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error verifying payment method: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

# Example: Credit a payment method
puts "Crediting a payment method (issuing a refund)..."
begin
  # Check if we have a payment method ID from the previous examples
  if defined?(payment_method_id) && payment_method_id
    # Credit the payment method
    transaction = client.credit_payment_method({
      payment_method_id: payment_method_id,
      total: 1.00,
      meta: {
        memo: 'Refund for Subscription',
        subtotal: '1.00',
        tax: '0'
      }
    })
    
    puts "Credit transaction completed!"
    puts "Transaction ID: #{transaction.id}"
    puts "Type: #{transaction.type}"
    puts "Status: #{transaction.success ? 'Success' : 'Failed'}"
    if transaction.success
      puts "Amount: $#{transaction.total}"
      puts "Method: #{transaction.method}"
      puts "Created at: #{transaction.created_at}"
      
      # Display payment method details
      if transaction.payment_method
        puts "Payment method: #{transaction.payment_method[:nickname]}"
        puts "Last four: #{transaction.last_four}"
      end
      
      # Display customer details
      if transaction.customer
        puts "Customer: #{transaction.customer[:firstname]} #{transaction.customer[:lastname]}"
        puts "Email: #{transaction.customer[:email]}"
      end
      
      puts "\nCredit (refund) was successfully issued to the customer's payment method."
    else
      puts "Error message: #{transaction.message}"
      puts "\nCredit transaction failed. The payment method may be invalid or the transaction was declined."
    end
    puts
  else
    puts "No payment method available for crediting. Please add a payment method to a customer first."
    puts
  end
rescue StaxPayments::StaxError => e
  puts "Error crediting payment method: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Error details: #{e.error_details}"
  puts
end

puts "=== Payment Examples Completed ==="
puts "=== All Payment Examples Completed ===" 